defmodule ACOTest do
  use ExUnit.Case
  doctest ACO

  describe "parse headers" do
    test "parse EUC_2D header" do
      header =
        """
        NAME : a280
        COMMENT : drilling problem (Ludwig)
        TYPE : TSP
        DIMENSION: 280
        EDGE_WEIGHT_TYPE : EUC_2D
        NODE_COORD_SECTION
        """

      {header, rest} = ACO.Graph.parse_tsp_file(header)

      assert header == [
               data_format: :node_coord_section,
               dims: 280,
               name: "a280",
               type: :euc_2d
             ]

      assert is_list(rest)
    end

    test "parse EXPLICIT header" do
      header =
        """
        NAME: bays29
        TYPE: TSP
        COMMENT: 29 cities in Bavaria, street distances (Groetschel,Juenger,Reinelt)
        DIMENSION: 29
        EDGE_WEIGHT_TYPE: EXPLICIT
        EDGE_WEIGHT_FORMAT: FULL_MATRIX
        DISPLAY_DATA_TYPE: TWOD_DISPLAY
        EDGE_WEIGHT_SECTION
        """

      {header, rest} = ACO.Graph.parse_tsp_file(header)

      assert header == [
               data_format: :edge_weight_section,
               dims: 29,
               name: "bays29",
               type: :explicit
             ]

      assert is_list(rest)
    end

    test "parse ATT header" do
      header =
        """
        NAME : att532
        TYPE : TSP
        COMMENT : 532-city problem (Padberg/Rinaldi)
        DIMENSION : 532
        EDGE_WEIGHT_TYPE : ATT
        NODE_COORD_SECTION
        """

      {header, rest} = ACO.Graph.parse_tsp_file(header)

      assert header == [
               data_format: :node_coord_section,
               dims: 532,
               name: "att532",
               type: :att
             ]

      assert is_list(rest)
    end
  end
end
