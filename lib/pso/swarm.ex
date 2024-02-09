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
      Enum.map(1..state[:population_size], fn id ->
        Supervisor.child_spec({PSO.Particle, pso_args}, id: id)
      end)

    Supervisor.init(children, strategy: :one_for_one)
  end
end
