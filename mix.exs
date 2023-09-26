defmodule Bia.MixProject do
  use Mix.Project

  def project do
    [
      app: :bia,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nx, ">= 0.0.0"},
      {:nimble_options, ">= 0.5.2"},
      {:exla, ">= 0.6.0", optional: true}
    ]
  end
end
