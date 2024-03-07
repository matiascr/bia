defmodule ACO.Ant do
  use GenServer

  @doc false
  def start_link(pso_args, opts \\ []) do
    GenServer.start_link(__MODULE__, pso_args, opts)
  end

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end
end
