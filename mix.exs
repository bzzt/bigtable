defmodule Bigtable.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :bigtable,
      version: @version,
      package: package(),
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      name: "Bigtable",
      homepage_url: "https://github.com/bzzt/bigtable",
      source_url: "https://github.com/bzzt/bigtable",
      deps: deps(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, codecov: :test]
    ]
  end

  defp package() do
    [
      description: "Elixir client library for Google Bigtable.",
      maintainers: ["Jason Scott", "Philip Prophet", "Daniel Fredriksson"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/bzzt/bigtable"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Bigtable, []},
      extra_applications: [:logger, :grpc]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp docs do
    [
      source_ref: "v#{@version}",
      extra_section: "GUIDES",
      main: "overview",
      formatters: ["html", "epub"],
      groups_for_modules: groups_for_modules(),
      extras: extras(),
      groups_for_extras: groups_for_extras()
    ]
  end

  defp extras do
    [
      "guides/introduction/overview.md",
      "guides/introduction/installation.md"
      # "guides/operations/read_rows.md"
    ]
  end

  defp groups_for_extras do
    [
      Introduction: ~r/guides\/introduction\/.?/
      # Operations: ~r/guides\/operations\/.?/
    ]
  end

  defp groups_for_modules do
    [
      "Typed Bigtable": [
        Bigtable.Schema
      ],
      Operations: [
        Bigtable.ReadRows,
        Bigtable.MutateRow,
        Bigtable.MutateRows
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 3.1"},
      {:lens, "~> 0.8.0"},
      {:goth, "~> 0.11.0"},
      {:credo, "~> 1.0.0", only: [:dev, :test, :ci], runtime: false},
      {:excoveralls, "~> 0.10", only: [:dev, :test, :ci]},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false},
      {:protobuf, "~> 0.5.3"},
      {:google_protos, "~> 0.1"},
      {:grpc, "~> 0.3.1"}
    ]
  end
end
