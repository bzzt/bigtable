# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module
use Mix.Config

config :goth,
  json: Path.absname("./secret/service.json") |> File.read!()

config :bigtable,
  project: "datahub-222411",
  instance: "dev-instance",
  table: "taxi"
