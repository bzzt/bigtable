use Mix.Config

config :bigtable,
  project: "dev",
  instance: "dev",
  table: "test",
  endpoint: "localhost:9035",
  ssl: false
