defmodule PsoTest do
  use ExUnit.Case
  doctest Bia.PSO

  test "run_pso" do
    bound_down = -1.0
    bound_up = 1.0

    {:ok, tensor, _} =
      Bia.PSO.new(
        population_size: 2,
        num_iterations: 2,
        bound_down: bound_down,
        bound_up: bound_up,
        dimensions: 5
      )
      |> Bia.PSO.run()

    Enum.each(tensor |> Nx.to_list(), fn i -> assert i <= bound_up and i >= bound_down end)
  end
end
