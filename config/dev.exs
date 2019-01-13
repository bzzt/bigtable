# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :bigtable,
  project: "datahub-222411",
  instance: "datahub",
  table: "ride",
  host: "localhost",
  port: 8086
