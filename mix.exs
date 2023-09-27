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
      before_closing_body_tag: &before_closing_body_tag/1,
      groups_for_modules: [
        "Particle Swarm Optimization": [
          Bia.PSO,
          Bia.PSO.Swarm,
          Bia.PSO.Particle
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

  defp before_closing_body_tag(:html) do
    """
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.13.19/dist/katex.min.css" integrity="sha384-beuqjL2bw+6DBM2eOpr5+Xlw+jiH44vMdVQwKxV28xxpoInPHTVmSvvvoPq9RdSh" crossorigin="anonymous">
    <script defer src="https://cdn.jsdelivr.net/npm/katex@0.13.19/dist/katex.min.js" integrity="sha384-aaNb715UK1HuP4rjZxyzph+dVss/5Nx3mLImBe9b0EW4vMUkc1Guw4VRyQKBC0eG" crossorigin="anonymous"></script>
    <script defer src="https://cdn.jsdelivr.net/npm/katex@0.13.19/dist/contrib/auto-render.min.js" integrity="sha384-+XBljXPPiv+OzfbB3cVmLHf4hdUFHlWNZN5spNQ7rmHTXpd7WvJum6fIACpNNfIR" crossorigin="anonymous"
            onload="renderMathInElement(document.body);"></script>
    <script>
      document.addEventListener("DOMContentLoaded", function() {
        renderMathInElement(document.body, {
          delimiters: [
            { left: "$$", right: "$$", display: true },
            { left: "$", right: "$", display: false },
          ]
        });
      });
    </script>
    """
  end

  defp before_closing_body_tag(_), do: ""
end
