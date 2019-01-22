# Installation

## Mix Dependency

```elixir
#mix.exs
def deps do
  [
    {:bigtable, "~> 0.1.0"},
  ]
end
```

## Configuration

#### Local Development Using Bigtable Emulator

```elixir
#dev.exs
config :bigtable,
  project: "project_id",
  instance: "instance_id",
  table: "table_name",
  endpoint: "localhost:8086"
  ssl: false
```

#### Production Configuration

```elixir
#prod.exs
config :bigtable,
  project: "project_id",
  instance: "instance_id",
  table: "table_name"
```
