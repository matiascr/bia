defmodule Bia.MixProject do
  use Mix.Project

  @source_url "https://github.com/matiascr/bia"

  def project do
    [
      app: :bia,
      name: "Bia",
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      source_url: @source_url,
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},
      {:nx, ">= 0.6.0"},
      {:nimble_options, ">= 0.5.2"},
      {:exla, ">= 0.6.0", optional: true}
    ]
  end

  defp docs do
    [
      main: "Bia",
      source_url: @source_url,
      extra_section: "Guides",
      extras: [
        "README.md",
        "notebooks/pso_example.livemd"
      ],
      groups_for_modules: [
        Heuristics: [
          PSO
        ]
      ],
      before_closing_body_tag: &before_closing_body_tag/1
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
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.13.0/dist/katex.min.css" integrity="sha384-t5CR+zwDAROtph0PXGte6ia8heboACF9R5l/DiY+WZ3P2lxNgvJkQk5n7GPvLMYw" crossorigin="anonymous">
    <script defer src="https://cdn.jsdelivr.net/npm/katex@0.13.0/dist/katex.min.js" integrity="sha384-FaFLTlohFghEIZkw6VGwmf9ISTubWAVYW8tG8+w2LAIftJEULZABrF9PPFv+tVkH" crossorigin="anonymous"></script>
    <script defer src="https://cdn.jsdelivr.net/npm/katex@0.13.0/dist/contrib/auto-render.min.js" integrity="sha384-bHBqxz8fokvgoJ/sc17HODNxa42TlaEhB+w8ZJXTc2nZf1VgEaFZeZvT4Mznfz0v" crossorigin="anonymous"></script>
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
    <script src="https://cdn.jsdelivr.net/npm/vega@5.20.2"></script>
    <script src="https://cdn.jsdelivr.net/npm/vega-lite@5.1.1"></script>
    <script src="https://cdn.jsdelivr.net/npm/vega-embed@6.18.2"></script>
    <script>
      document.addEventListener("DOMContentLoaded", function () {
        for (const codeEl of document.querySelectorAll("pre code.vega-lite")) {
          try {
            const preEl = codeEl.parentElement;
            const spec = JSON.parse(codeEl.textContent);
            const plotEl = document.createElement("div");
            preEl.insertAdjacentElement("afterend", plotEl);
            vegaEmbed(plotEl, spec);
            preEl.remove();
          } catch (error) {
            console.log("Failed to render Vega-Lite plot: " + error)
          }
        }
      });
    </script>
    """
  end

  defp before_closing_body_tag(_), do: ""
end
