defmodule Bigtable.MixProject do
  use Mix.Project

  alias Bigtable.{Admin, Connection}

  @version "0.7.0"

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
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        "coveralls.json": :test,
        "coveralls.html": :test,
        coverage: :test
      ]
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
      extra_applications: [:logger, :grpc, :db_connection]
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
      groups_for_extras: groups_for_extras(),
      nest_modules_by_prefix: [
        Bigtable.ChunkReader
      ]
    ]
  end

  defp extras do
    [
      "guides/introduction/overview.md",
      "guides/introduction/installation.md"
    ]
  end

  defp groups_for_extras do
    [
      Introduction: ~r/guides\/introduction\/.?/
    ]
  end

  defp groups_for_modules do
    [
      Admin: [
        Admin.GcRule,
        Admin.Modification,
        Admin.Table,
        Admin.TableAdmin
      ],
      Connection: [
        Connection
      ],
      Data: [
        Bigtable.CheckAndMutateRow,
        Bigtable.ChunkReader,
        Bigtable.ChunkReader.ReadCell,
        Bigtable.MutateRow,
        Bigtable.MutateRows,
        Bigtable.Mutations,
        Bigtable.ReadModifyWriteRow,
        Bigtable.ReadRows,
        Bigtable.RowFilter,
        Bigtable.RowSet,
        Bigtable.SampleRowKeys
      ]
    ]
  end

  defp aliases do
    [
      coverage: [
        "coveralls.json"
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:db_connection, "~> 2.0.6"},
      {:google_protos, "~> 0.1"},
      {:goth, "~> 0.11.0"},
      # {:grpc, "~> 0.3.1"},
      {:grpc, "~> 0.4.0-alpha.2"},
      {:poison, "~> 3.1"},
      {:protobuf, "~> 0.5.3"},
      # Dev Deps
      {:credo, "~> 1.0.0", only: [:dev, :test, :ci], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.10", only: [:dev, :test, :ci]},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false}
    ]
  end
end
