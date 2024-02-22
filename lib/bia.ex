defmodule Bia do
  @moduledoc """
  Documentation for `Bia`, a bio-inspired algorithms library written in Elixir.
  """
end

defmodule Bia.Heuristic do
  @moduledoc false

  @type supervisor() :: pid()
  @type config() :: keyword()
  @type results() :: map()

  @callback new(keyword()) :: {supervisor(), config()}
  @callback run({supervisor(), config()}) :: results()
end
