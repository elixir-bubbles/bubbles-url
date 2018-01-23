defmodule Bubbles.Url.Mixfile do
  use Mix.Project

  def project do
    [
      app: :bubbles_url,
      version: "0.1.0",
      description: "Elixir library for managing URLs as Ecto schema",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      name: "MyApp",
      source_url: "https://github.com/elixir-bubbles/bubbles_url",
      docs: [
        main: "Bubbles.Url"
        # logo: "path/to/logo.png"
      ],
      package: [
        licenses: ["MIT"],
        files: ["lib", "mix.exs", "README*"],
        maintainers: ["Martin Vrkljan"],
        links: %{"GitHub" => "https://github.com/elixir-bubbles/bubbles_url"}
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: applications(Mix.env())
    ]
  end

  defp applications(:test), do: [:postgrex, :ecto, :logger]
  defp applications(_), do: [:logger]

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 2.2"},
      {:ex_doc, "~> 0.18.0", only: :dev, runtime: false},
      {:postgrex, "~> 0.11.0 or ~> 0.12.0 or ~> 0.13.0", optional: true}
    ]
  end
end
