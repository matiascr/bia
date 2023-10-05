defmodule PSO do
  @moduledoc """
  Implementation of Particle Swarm Optimization in Elixir.

  Velocity is updated with

  $$
  v_{i,d} \\leftarrow \\omega v_{i,d} + \\phi_p r_p (p_{i,d}-x_{i,d}) + \\phi_g r_g (g_d-x_{i,d})
  $$
  """
  require Nx

  @type supervisor() :: pid()
  @type config() :: keyword()
  @type results() :: map()

  opts = [
    population_size: [
      type: :pos_integer,
      default: 10,
      doc: """
      The number of particles to be used in the optimization.
      """
    ],
    num_iterations: [
      type: :non_neg_integer,
      default: 100,
      doc: """
      The number of iterations to be done in the optimization.
      """
    ],
    dimensions: [
      type: :pos_integer,
      default: 2,
      doc: """
      The dimensions of the search space.
      """
    ],
    bound_up: [
      type: :float,
      default: 5.12,
      doc: """
      The upper boundary of the search space.
      """
    ],
    bound_down: [
      type: :float,
      default: -5.12,
      doc: """
      The lower boundary of the search space.
      """
    ],
    inertia: [
      type: :float,
      default: 0.6,
      doc: """
      The inertia each particle carries each move. Should be smaller than 1.
      """
    ],
    coeff_p: [
      type: :float,
      default: 1.0,
      doc: """
      The cognitive coefficient.
      """
    ],
    coeff_g: [
      type: :float,
      default: 3.0,
      doc: """
      The social coefficient.
      """
    ],
    fun: [
      type: {:fun, 1},
      default: &Nx.sum(&1),
      doc: """
      The function to optimize.
      """
    ],
    callback: [
      type: {:fun, 1},
      default: &PSO.callback(&1),
      doc: """
      The function to optimize.
      """
    ],
    widget: [
      type: :any,
      default: nil,
      doc: """
      A widget for getting the data visualized.
      """
    ]
  ]

  @opts_schema NimbleOptions.new!(opts)

  @doc """
  Creates a new instance of a PSO.

  ## Options

  #{NimbleOptions.docs(@opts_schema)}

  ## Return Values

    The function returns a tuple of two values:

    * `supervisor` - the pid of the created Swarm supervisor.

    * `opts` - the parameters of the initialized Swarm.
  """
  @spec new(keyword(any())) :: {supervisor(), config()}
  def new(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @opts_schema)

    particle_opts =
      opts
      |> Map.new()
      |> Map.drop([:callback, :widget])

    {:ok, supervisor} = Supervisor.start_link(PSO.Swarm, {:ok, particle_opts}, opts)

    {supervisor, opts}
  end

  @doc """
  Runs a given instance of an initialized Swarm with pid `supervisor` and options `opts`.

  ## Return Values

    The function returns a map with the following:

    * `best_position` - the position of the best result found.

    * `best` - the best result found.
  """
  @spec run({supervisor(), config()}) :: results()
  def run({supervisor, opts}) do
    fun = opts[:fun]
    callback = opts[:callback]

    particles =
      supervisor
      |> Supervisor.which_children()
      |> Enum.map(fn {_, particle, _, _} -> particle end)

    # Update the swarm's best known position
    global_best = particles |> get_global_best_position(fun)

    callback.(opts: opts, particles: particles, global_best: global_best)

    # Iterate
    result_position =
      Enum.reduce(1..opts[:num_iterations]//1, global_best, fn _, gb ->

        # Move particles
        Enum.map(particles, &GenServer.call(&1, {:move, gb}))
        # Get particle position with best result
        iterations_best = particles |> get_global_best_position(fun)
        # Update global best if the newest is better
        new_global_best =
          if fun.(gb) |> Nx.greater(fun.(iterations_best)),
            do: iterations_best,
            else: gb

        callback.(opts: opts, particles: particles, global_best: new_global_best)

        new_global_best
      end)

    # Kill the processes
    Supervisor.stop(supervisor)

    %{
      best_position: result_position,
      best: fun.(result_position)
    }
  end

  defp get_global_best_position(particles, fun) do
    particles
    |> Enum.map(&GenServer.call(&1, :get_best))
    |> Enum.min_by(fn x -> fun.(x) |> Nx.to_number() end)
  end

  def callback(_), do: nil
end
