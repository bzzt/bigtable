# Installation

## Mix Dependency

```elixir
#mix.exs
def deps do
  [
    {:bigtable, "~> 0.7.0"},
  ]
end
```

## Configuration

#### Local Development Using Bigtable Emulator

```elixir
#dev.exs
config :bigtable,
  project: "project",
  instance: "instance",
  table: "table_name", # Default table name to use in requests
  endpoint: "localhost:9035",
  ssl: false

config :goth,
  disabled: true
```

#### Production Configuration

```elixir
#prod.exs
config :bigtable,
  project: "project_id",
  instance: "instance_id",
  # Default table name to use in requests
  table: "table_name",
  # Optional connection pool size. Defaults to 128
  pool_size: 128,
  # Optional connection pool overflow when size is exceeded
  pool_overflow: 128
```
