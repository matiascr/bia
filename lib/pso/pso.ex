defmodule Bia.PSO do
  @moduledoc """
  Implementation of Particle Swarm Optimization in Elixir.
  """
  require Nx

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
      default: 2
    ],
    bound_up: [
      type: :float,
      default: 5.12
    ],
    bound_down: [
      type: :float,
      default: -5.12
    ],
    inertia: [
      type: :float,
      default: 0.6,
      doc: """
      Should be smaller than 1
      """
    ],
    coef_p: [
      type: :float,
      default: 1.0
    ],
    coef_g: [
      type: :float,
      default: 3.0
    ]
  ]

  @opts_schema NimbleOptions.new!(opts)
  def new(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @opts_schema)

    {:ok, supervisor} = Supervisor.start_link(Bia.PSO.Swarm, {:ok, Map.new(opts)}, opts)

    {supervisor, opts}
  end

  def run({supervisor, opts}) do
    # Initialize particlesm (vector and position)
    particles =
      Supervisor.which_children(supervisor)
      |> Enum.map(fn {_, particle, _, _} -> particle end)

    # Get the first global best
    global_best = get_global_best_position(particles)

    result =
      Enum.reduce(0..opts[:num_iterations], global_best, fn _, global_best ->
        # Move particles
        Enum.map(particles, &GenServer.call(&1, {:move, global_best}))
        # Get particle position with best result
        iterations_best = get_global_best_position(particles)
        # Update global best if the newest is better
        if Nx.sum(global_best) > Nx.sum(iterations_best), do: iterations_best, else: global_best
      end)

    # Kill the processes
    Supervisor.stop(supervisor)

    # Return the best position and the best result
    {:ok, result, Nx.sum(result)}
  end

  def get_global_best_position(particles) do
    particles
    |> Enum.map(&GenServer.call(&1, :get_best))
    |> Enum.min_by(fn x -> Nx.sum(x) |> Nx.to_number() end)
  end
end
