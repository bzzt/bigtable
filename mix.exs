defmodule Bigtable.MixProject do
  use Mix.Project

  def project do
    [
      app: :bigtable,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Bigtable, []},
      extra_applications: [:logger, :grpc]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [{:protobuf, "~> 0.5.3"}, {:google_protos, "~> 0.1"}, {:grpc, github: "tony612/grpc-elixir"}]
  end
end
