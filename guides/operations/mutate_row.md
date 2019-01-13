### Mutate Row

#### SetCell

```elixir
alias Bigtable.{Mutations, MutateRow}

Mutations.build("Ride#123")
|> Mutations.set_cell("ride", "foo", "bar")
|> MutateRow.mutate
```

#### DeleteFromColumn

```elixir
alias Bigtable.{Mutations, MutateRow}

Mutations.build("Ride#123")
|> Mutations.delete_from_column("ride", "foo")
|> MutateRow.mutate
```

#### DeleteFromFamily

```elixir
alias Bigtable.{Mutations, MutateRow}

Mutations.build("Ride#123")
|> Mutations.delete_from_family("ride")
|> MutateRow.mutate
```

#### DeleteFromRow

```elixir
alias Bigtable.{Mutations, MutateRow}

Mutations.build("Ride#123")
|> Mutations.delete_from_row()
|> MutateRow.mutate
```
