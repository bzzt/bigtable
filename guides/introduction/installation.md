# Installation

## Mix Dependency

```elixir
#mix.exs
def deps do
  [
    {:bigtable, "~> 0.1"},
  ]
end
```

## Configuration

```elixir
#config.exs
config :bigtable,
  project: "project_id",
  instance: "instance_id",
  table: "table_name",
  url: "localhost:8086"

```
