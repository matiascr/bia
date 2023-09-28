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
      type: :pos_integer,
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
    coef_p: [
      type: :float,
      default: 1.0,
      doc: """
      The cognitive coefficient.
      """
    ],
    coef_g: [
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
    opts =
      NimbleOptions.validate!(opts, @opts_schema)

    # |> Keyword.drop([:fun])

    {:ok, supervisor} = Supervisor.start_link(PSO.Swarm, {:ok, Map.new(opts)}, opts)

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
    # Initialize particles (vector and position)
    particles =
      Supervisor.which_children(supervisor)
      |> Enum.map(fn {_, particle, _, _} -> particle end)

    # Get the first global best
    global_best = get_global_best_position(particles, opts[:fun])

    result_position =
      Enum.reduce(0..opts[:num_iterations], global_best, fn _, global_best ->
        # Move particles
        Enum.map(particles, &GenServer.call(&1, {:move, global_best}))
        # Get particle position with best result
        iterations_best = get_global_best_position(particles, opts[:fun])
        # Update global best if the newest is better
        if opts[:fun].(global_best) > opts[:fun].(iterations_best),
          do: iterations_best,
          else: global_best
      end)

    # Kill the processes
    Supervisor.stop(supervisor)

    %{
      best_position: result_position,
      best: opts[:fun].(result_position)
    }
  end

  defp get_global_best_position(particles, fun) do
    particles
    |> Enum.map(&GenServer.call(&1, :get_best))
    |> Enum.min_by(fn x -> fun.(x) |> Nx.to_number() end)
  end
end
