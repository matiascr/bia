defmodule Bia.PSO.Swarm do
  @moduledoc """
  Implementation of a swarm.
  """
  use Supervisor

  @doc """
  Starts the particles
  """
  def init({:ok, state}) do
    [
      "Starting PSO of",
      Integer.to_string(state[:population_size]),
      "and",
      Integer.to_string(state[:num_iterations]),
      "iterations..."
    ]
    |> Enum.join(" ")
    |> IO.puts()

    pso_args =
      state
      |> Map.drop([:population_size, :num_iterations])

    children =
      1..state[:population_size]
      |> Enum.map(fn id ->
        %{
          id: id,
          start:
            {Bia.PSO.Particle, :start_link, [pso_args, [name: String.to_atom("particle_#{id}")]]}
        }
      end)

    Supervisor.init(children, strategy: :one_for_one)
  end
end
