defmodule Bia.PSO.Particle do
  @moduledoc ~S"""
  Implementation of a particle.

  Velocity is updated with

  $$
  v_{i,d} \\leftarrow \\omega v_{i,d} + \\phi_p r_p (p_{i,d}-x_{i,d}) + \\phi_g r_g (g_d-x_{i,d})
  $$
  """
  use GenServer

  require Nx
  import Nx.Defn

  def start_link(pso_args, opts \\ []) do
    GenServer.start_link(__MODULE__, pso_args, opts)
  end

  def init(pso_args) do
    {:ok, initialize_particle(pso_args)}
  end

  defp initialize_particle(pso_args) do
    pso_args
    |> Map.merge(initialize_position(pso_args.dimensions, pso_args.bound_up, pso_args.bound_down))
    |> Map.merge(initialize_velocity(pso_args.dimensions, pso_args.bound_up, pso_args.bound_down))
    |> then(&Map.merge(&1, %{personal_best: &1.position}))
  end

  defp initialize_position(dimensions, bound_up, bound_down) do
    initial_position = random_uniform_tensor(dimensions, bound_down, bound_up)

    %{position: initial_position, personal_best: initial_position}
  end

  defp initialize_velocity(dimensions, bound_up, bound_down) do
    domain = abs(bound_up - bound_down)

    initial_velocity = random_uniform_tensor(dimensions, -domain, domain)

    %{velocity: initial_velocity}
  end

  def handle_cast({:set_best, global_best}, state) do
    {:noreply, %{state | global_best: global_best}}
  end

  def handle_call({:move, global_best}, _from, state) do
    random_p = random_uniform_tensor(state.dimensions)
    random_g = random_uniform_tensor(state.dimensions)

    new_velocity = update_velocity(state, random_p, random_g, global_best)

    new_position =
      state.position
      |> update_position(new_velocity)
      |> bound_position(state.bound_up, state.bound_down)

    personal_best =
      if Nx.sum(state.position) > Nx.sum(new_position), do: new_position, else: state.position

    new_state =
      state
      |> Map.merge(%{velocity: new_velocity})
      |> Map.merge(%{position: new_position})
      |> Map.merge(%{personal_best: personal_best})

    {:reply, personal_best, new_state}
  end

  def handle_call(:get_best, _from, state) do
    {:reply, state.personal_best, state}
  end

  defn update_velocity(state, random_p, random_g, global_best) do
    (state.inertia * state.velocity)
    |> Nx.add(state.coef_p * random_p * (state.personal_best - state.position))
    |> Nx.add(state.coef_g * random_g * (global_best - state.position))
  end

  defn update_position(position, velocity) do
    position + velocity
  end

  defp bound_position(position, bound_up, bound_down) do
    position
    |> Nx.to_flat_list()
    |> Enum.map(fn i ->
      cond do
        i > bound_up -> bound_up
        i < bound_down -> bound_down
        true -> i
      end
    end)
    |> Nx.tensor(type: :f64)
  end

  defp random_uniform_tensor(dimensions, bound_down \\ 0.0, bound_up \\ 1.0) do
    Enum.random(0..1701)
    |> Nx.Random.key()
    |> Nx.Random.uniform(bound_down, bound_up, shape: {dimensions}, type: :f64)
    |> elem(0)
  end
end
