defmodule ACO.Graph do
  @moduledoc false
  use GenServer

  import Nx.Defn

  require Nx

  @discarded_header_keys ~w(TYPE COMMENT CAPACITY EDGE_WEIGHT_FORMAT
                            EDGE_DATA_FORMAT NODE_COORD_TYPE
                            DISPLAY_DATA_TYPE EOF)

  @data_formats ~w(NODE_COORD_SECTION DEPOT_SECTION
                   DEMAND_SECTION EDGE_DATA_SECTION FIXED_EDGES_SECTION
                   DISPLAY_DATA_SECTION TOUR_SECTION EDGE_WEIGHT_SECTION)

  @type graph_format ::
          :node_coord_section
          | :depot_section
          | :demand_section
          | :edge_data_section
          | :fixed_edges_section
          | :display_data_section
          | :tour_section
          | :edge_weight_section

  @type edge_weight_type ::
          :att
          | :explicit
          | :lower_diag_row
          | :euc_2d
          | :geo
          | :ceil_2d
  @type graph_info :: [dims: pos_integer(), name: String.t(), type: edge_weight_type()]
  @type graph :: Nx.Tensor.t()

  @doc false
  def start_link(aco_args, opts \\ []) do
    GenServer.start_link(__MODULE__, aco_args, opts)
  end

  @impl true
  def init(aco_args) do
    {:ok, initialize_graph(aco_args)}
  end

  defp initialize_graph(aco_args) do
    {:ok, file} = File.read(aco_args.file_name)

    tsp = parse_tsp_file(file)
  end

  defn get_length(path) do
  end

  defn add_pheromones(graph, path) do
  end

  @spec compute_distance_matrix(Nx.Tensor.t(), graph_format()) :: Nx.Tensor.t()
  def compute_distance_matrix(graph, format) do
  end

  @spec parse_tsp_file(binary()) :: {graph_info(), graph()}
  def parse_tsp_file(file) do
    file_lines = String.split(file, "\n")

    {header, rest} =
      file_lines
      |> Enum.filter(&(&1 != ""))
      |> Enum.reduce({[], []}, fn line, {h, r} ->
        [keyword, value] =
          try do
            [keyword, value] =
              String.split(line, [": "], parts: 2, trim: true)
          rescue
            MatchError -> [line, ""]
          end

        cond do
          keyword =~ "NAME" ->
            {[{:name, value} | h], r}

          keyword =~ "DIMENSION" ->
            {[{:dims, String.to_integer(value)} | h], r}

          keyword =~ "EDGE_WEIGHT_TYPE" ->
            {[{:type, String.downcase(value) |> String.to_atom()} | h], r}

          Enum.member?(@data_formats, keyword) ->
            {[{:data_format, String.downcase(keyword) |> String.to_atom()} | h], r}

          Enum.member?(@discarded_header_keys, keyword) ->
            {h, r}

          true ->
            {h, [line | r]}
        end
      end)

    header =
      header
      |> Keyword.validate!([:name, :dims, :type, :data_format])
      |> Enum.sort()

    {header, rest}
  end
end
