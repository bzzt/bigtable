use Mix.Config

config :bigtable,
  project: "dev",
  instance: "dev",
  table: "dev",
  endpoint: "localhost:9035",
  ssl: false

config :mix_test_watch,
  tasks: [
    "test"
  ],
  clear: true
