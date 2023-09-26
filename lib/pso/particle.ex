defmodule Bia.PSO.Particle do
  @moduledoc """
  Implementation of a particle.

  Velocity is updated with
  $$
  v_{i,d} ← w v_{i,d} + φ_p r_p (p_{i,d}-x_{i,d}) + φ_g r_g (g_d-x_{i,d})
  $$
  """

  use GenServer

  alias Nx
  import Nx.Defn

  def start_link(pso_args, opts \\ []) do
    GenServer.start_link(__MODULE__, pso_args, opts)
  end

  def init(pso_args) do
    {:ok, initialize_particle(pso_args)}
  end

  def initialize_particle(pso_args) do
    pso_args
    |> Map.merge(initialize_position(pso_args.dimensions, pso_args.bound_up, pso_args.bound_down))
    |> Map.merge(initialize_velocity(pso_args.dimensions, pso_args.bound_up, pso_args.bound_down))
    |> then(&Map.merge(&1, %{personal_best: &1.position}))
  end

  def initialize_position(dimensions, bound_up, bound_down) do
    initial_position = random_uniform_tensor(dimensions, bound_down, bound_up)

    %{position: initial_position, personal_best: initial_position}
  end

  def initialize_velocity(dimensions, bound_up, bound_down) do
    domain = abs(bound_up - bound_down)

    initial_velocity = random_uniform_tensor(dimensions, -domain, domain)

    %{velocity: initial_velocity}
  end

  def random_uniform_tensor(dimensions, bound_up, bound_down) do
    Enum.random(0..1701)
    |> Nx.Random.key()
    |> Nx.Random.uniform(bound_up, bound_down, shape: {dimensions}, type: :f64)
    |> elem(0)
  end

  def handle_cast(:say_hello, state) do
    {:noreply, state}
  end

  def handle_cast({:set_best, global_best}, state) do
    {:noreply, %{state | global_best: global_best}}
  end

  @doc """
  Update velocity as
  $$
  v_{i,d} ← w v_{i,d} + φ_p r_p (p_{i,d}-x_{i,d}) + φ_g r_g (g_d-x_{i,d})
  $$
  """
  def handle_call({:move, global_best}, _from, state) do
    random_g = random_uniform_tensor(state.dimensions, state.bound_up, state.bound_down)
    random_p = random_uniform_tensor(state.dimensions, state.bound_up, state.bound_down)

    new_velocity = update_velocity(state, random_p, random_g, global_best)

    new_position = update_position(new_velocity, state.position)

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
    state.inertia * state.velocity +
      state.coef_p * random_p * (state.personal_best - state.position) +
      state.coef_g * random_g * (global_best - state.position)
  end

  defn update_position(velocity, position) do
    velocity + position
  end
end
