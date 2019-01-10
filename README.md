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
alias Bigtable.Operations
alias Bigtable.ReadRows.Request

Request.build()
|> Operations.read_rows()
```

##### With Row Key:

```elixir
alias Bigtable.Operations
alias Bigtable.ReadRows.Request
alias Bigtable.RowSet

Request.build()
|> RowSet.row_keys("Ride#123")
|> Operations.read_rows()
```

##### With Row Range:

```elixir
alias Bigtable.Operations
alias Bigtable.ReadRows.Request
alias Bigtable.RowRange

Request.build()
|> RowRange.inclusive("Ride#121", "Ride#124")
|> Operations.read_rows()
```

##### With Optional Filters:

```elixir
alias Bigtable.Operations
alias Bigtable.ReadRows.Request
alias Bigtable.RowRange

Request.build()
|> RowRange.inclusive("Ride#121", "Ride#124")
|> Operations.read_rows()
```

## Mutations

### SetCell

```elixir
alias Bigtable.Operations
alias Bigtable.MutateRow.Request

mutation = Bigtable.Mutation.build("Ride#123")
|> Bigtable.Mutation.set_cell("ride", "foo", "bar")

Request.build(mutation)
|> Operations.mutate_row
```

### DeleteFromColumn

```elixir
alias Bigtable.Operations
alias Bigtable.MutateRow.Request

mutation = Bigtable.Mutation.build("Ride#123")
|> Bigtable.Mutation.delete_from_column("ride", "foo")

Request.build(mutation)
|> Operations.mutate_row
```

### DeleteFromFamily

```elixir
alias Bigtable.Operations
alias Bigtable.MutateRow.Request

mutation = Bigtable.Mutation.build("Ride#123")
|> Bigtable.Mutation.delete_from_family("ride")

Request.build(mutation)
|> Operations.mutate_row
```

### DeleteFromRow

```elixir
alias Bigtable.Operations
alias Bigtable.MutateRow.Request

mutation = Bigtable.Mutation.build("Ride#123")
|> Bigtable.Mutation.delete_from_row()

Request.build(mutation)
|> Operations.mutate_row
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/bigtable](https://hexdocs.pm/bigtable).
