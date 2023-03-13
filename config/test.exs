import Config

config :goth,
  disabled: true

config :bigtable,
  project: "dev",
  instance: "dev",
  table: "test",
  endpoint: "localhost:9035",
  ssl: []
