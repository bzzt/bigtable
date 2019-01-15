# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :pre_commit,
  commands: ["test", "coveralls", "credo"],
  verbose: true

config :bigtable,
  project: "datahub-222411",
  instance: "datahub",
  table: "ride",
  url: "localhost:8086"
