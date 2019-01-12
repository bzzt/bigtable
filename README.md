# Bigtable

## Starting the BT Emulator

```bash
gcloud beta emulators bigtable start & $(gcloud beta emulators bigtable env-init)
cbt createtable ride && cbt createfamily ride ride
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `bigtable` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bigtable, "~> 0.1.0"}
  ]
end
```

# Operations

## Reads

#### Read Rows

##### All Rows:

```elixir
alias Bigtable.ReadRows

ReadRows.read()
```

```elixir
alias Bigtable.ReadRows

ReadRows.read("projects/[project_id]/instances/[instance_id]/tables/[table_name]")
```

##### With Row Key:

```elixir
alias Bigtable.{ReadRows, RowSet}

RowSet.row_keys("Ride#123")
|> ReadRows.read()
```

```elixir
alias Bigtable.{ReadRows, RowSet}

ReadRows.build("projects/[project_id]/instances/[instance_id]/tables/[table_name]")
|> RowSet.row_keys("Ride#123")
|> ReadRows.read()
```

#### With Row Keys:

```elixir
alias Bigtable.{ReadRows, RowSet}

RowSet.row_keys(["Ride#123", "Ride#124"])
|> ReadRows.read()
```

```elixir
alias Bigtable.{ReadRows, RowSet}

ReadRows.build("projects/[project_id]/instances/[instance_id]/tables/[table_name]")
|> RowSet.row_keys(["Ride#123", "Ride#124"])
|> ReadRows.read()
```

##### With Row Range:

```elixir
alias Bigtable.{ReadRows, RowSet}

RowSet.row_range("Ride#121", "Ride#124")
|> ReadRows.read()
```

```elixir
alias Bigtable.{ReadRows, RowSet}

RowSet.row_range("Ride#121", "Ride#124", false)
|> ReadRows.read()
```

```elixir
alias Bigtable.{ReadRows, RowSet}

ranges = [
  {"Ride#121", "Ride#124"},
  {"Ride#128", "Ride#131"}
]

RowSet.row_ranges(ranges)
|> ReadRows.read()
```

```elixir
alias Bigtable.{ReadRows, RowSet}

ranges = [
  {"Ride#121", "Ride#124"},
  {"Ride#128", "Ride#131"}
]

RowSet.row_ranges(ranges, false)
|> ReadRows.read()
```

```elixir
alias Bigtable.{ReadRows, RowSet}

ReadRows.build("projects/[project_id]/instances/[instance_id]/tables/[table_name]")
|> RowSet.row_range("Ride#121", "Ride#124")
|> ReadRows.read()
```

##### With Optional Filters:

```elixir
alias Bigtable.{ReadRows, RowSet}
alias ReadRows.Filter

RowSet.row_keys("Ride#123")
|> Filter.cells_per_column(5)
|> ReadRows.read()
```

## Mutations

### SetCell

```elixir
alias Bigtable.{Mutations, MutateRow}

Mutations.build("Ride#123")
|> Mutations.set_cell("ride", "foo", "bar")
|> MutateRow.build()
|> MutateRow.mutate
```

### DeleteFromColumn

```elixir
alias Bigtable.{Mutations, MutateRow}

Mutations.build("Ride#123")
|> Mutations.delete_from_column("ride", "foo")
|> MutateRow.build(mutation)
|> MutateRow.mutate
```

### DeleteFromFamily

```elixir
alias Bigtable.{Mutations, MutateRow}

Mutations.build("Ride#123")
|> Mutations.delete_from_family("ride")
|> MutateRow.build()
|> MutateRow.mutate
```

### DeleteFromRow

```elixir
alias Bigtable.{Mutations, MutateRow}

Mutations.build("Ride#123")
|> Mutations.delete_from_row()
|> MutateRow.build(mutation)
|> MutateRow.mutate
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/bigtable](https://hexdocs.pm/bigtable).
