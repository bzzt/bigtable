use Mix.Config

config :bigtable,
  project: "dev",
  instance: "dev",
  table: "test",
  endpoint: "bigtable-emulator:9035",
  ssl: false
