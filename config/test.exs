use Mix.Config

config :bigtable,
  project: "datahub-222411",
  instance: "dev-instance",
  table: "ride",
  endpoint: "localhost:8086",
  ssl: false
