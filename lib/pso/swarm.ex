defmodule PSO.Swarm do
  @moduledoc false
  use Supervisor

  require Nx

  @doc false
  def init({:ok, state}) do
    pso_args =
      state
      |> Map.drop([:population_size, :num_iterations])

    children =
      1..state[:population_size]
      |> Enum.map(fn id ->
        %{
          id: id,
          start: {PSO.Particle, :start_link, [pso_args, [name: String.to_atom("particle_#{id}")]]}
        }
      end)

    Supervisor.init(children, strategy: :one_for_one)
  end
end
