defmodule Bia.PSO do
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
      default: 1.0
    ],
    bound_down: [
      type: :float,
      default: -1.0
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
    {Supervisor.start_link(Bia.PSO.Swarm, {:ok, Map.new(opts)}, opts), opts[:num_iterations]}
  end

  def run({{:ok, supervisor_pid}, num_iterations}) do
    # Initialize particles
    particles =
      Supervisor.which_children(supervisor_pid)
      |> Enum.map(fn {_, particle, _, _} -> particle end)

    # Get the first global best
    global_best = get_global_best(particles)

    result =
      Enum.reduce(0..num_iterations, global_best, fn _, global_best ->
        particles
        |> Enum.map(&GenServer.call(&1, {:move, global_best}))

        iterations_best =
          particles
          |> get_global_best()

        Nx.sum(iterations_best)

        res =
          if Nx.sum(global_best) > Nx.sum(iterations_best), do: iterations_best, else: global_best

        res
      end)

    Supervisor.stop(supervisor_pid)

    {result, Nx.sum(result)}
  end

  def get_global_best(particles) do
    particles
    |> Enum.map(&GenServer.call(&1, :get_best))
    |> Enum.min_by(fn x -> Nx.sum(x) end)
  end
end
