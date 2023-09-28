defmodule Bia.MixProject do
  use Mix.Project

  @source_url "https://github.com/matiascr/bia"

  def project do
    [
      app: :bia,
      name: "Bia",
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      source_url: @source_url,
      deps: deps(),
      docs: docs(),
      package: package()
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
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},
      {:nx, ">= 0.0.0"},
      {:nimble_options, ">= 0.5.2"},
      {:exla, ">= 0.6.0", optional: true}
    ]
  end

  defp docs do
    [
      main: "Bia",
      source_url: @source_url,
      groups_for_modules: [
        Heuristics: [
          PSO
        ]
      ]
    ]
  end

  defp package do
    [
      maintainers: ["Matias Carlander-Reuterfelt"],
      description: "Bio inspired algorithms using Elixir",
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end
end
