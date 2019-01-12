# Table of Contents

- [Using the BT Emulator](#using-the-bt-emulator)
  - [Installing the emulator](#installing-the-emulator)
  - [Starting the emulator](#starting-the-emulator)
- [Bigtable Operations](#bigtable-operations)
  - [Read Rows](#read-rows)
    - [All Rows](#all-rows)
      - [Default Table](#default-table)
      - [Custom Table](#custom-table)
    - [Single Row Key](#single-row-key)
      - [Default Table](#default-table-1)
      - [Custom Table](#custom-table-1)
    - [Multiple Row Keys](#multiple-row-keys)
      - [Default Table](#default-table-2)
      - [Custom Table](#custom-table-2)
    - [Single Row Range](#single-row-range)
      - [Default Table (inclusive range)](#default-table-inclusive-range)
      - [Default Table (exclusive range)](#default-table-exclusive-range)
    - [Multiple Row Ranges](#multiple-row-ranges)
      - [Default Table (inclusive ranges)](#default-table-inclusive-ranges)
      - [Default Table (exclusive ranges)](#default-table-exclusive-ranges)
      - [Custom Table](#custom-table-3)
    - [Filtering Results](#filtering-results)
  - [Mutations](#mutations)
    - [Single Row](#single-row)
      - [SetCell](#setcell)
      - [DeleteFromColumn](#deletefromcolumn)
      - [DeleteFromFamily](#deletefromfamily)
      - [DeleteFromRow](#deletefromrow)

# Using the BT Emulator

Google's [bigtable emulator](https://cloud.google.com/bigtable/docs/emulator) can be used for easy local development and testing

## Installing the emulator

```bash
gcloud components update
gcloud components install beta cbt
```

## Starting the emulator

```bash
gcloud beta emulators bigtable start & $(gcloud beta emulators bigtable env-init)
cbt createtable ride && cbt createfamily ride ride
```

# Bigtable Operations

## Read Rows

### All Rows

#### Default Table

```elixir
alias Bigtable.ReadRows

ReadRows.read()
```

#### Custom Table

```elixir
alias Bigtable.ReadRows

ReadRows.read("projects/[project_id]/instances/[instance_id]/tables/[table_name]")
```

### Single Row Key

#### Default Table

```elixir
alias Bigtable.{ReadRows, RowSet}

RowSet.row_keys("Ride#123")
|> ReadRows.read()
```

#### Custom Table

```elixir
alias Bigtable.{ReadRows, RowSet}

ReadRows.build("projects/[project_id]/instances/[instance_id]/tables/[table_name]")
|> RowSet.row_keys("Ride#123")
|> ReadRows.read()
```

### Multiple Row Keys

#### Default Table

```elixir
alias Bigtable.{ReadRows, RowSet}

RowSet.row_keys(["Ride#123", "Ride#124"])
|> ReadRows.read()
```

#### Custom Table

```elixir
alias Bigtable.{ReadRows, RowSet}

ReadRows.build("projects/[project_id]/instances/[instance_id]/tables/[table_name]")
|> RowSet.row_keys(["Ride#123", "Ride#124"])
|> ReadRows.read()
```

### Single Row Range

#### Default Table (inclusive range)

```elixir
alias Bigtable.{ReadRows, RowSet}

RowSet.row_range("Ride#121", "Ride#124")
|> ReadRows.read()
```

#### Default Table (exclusive range)

```elixir
alias Bigtable.{ReadRows, RowSet}

RowSet.row_range("Ride#121", "Ride#124", false)
|> ReadRows.read()
```

### Multiple Row Ranges

#### Default Table (inclusive ranges)

```elixir
alias Bigtable.{ReadRows, RowSet}

ranges = [
  {"Ride#121", "Ride#124"},
  {"Ride#128", "Ride#131"}
]

RowSet.row_ranges(ranges)
|> ReadRows.read()
```

#### Default Table (exclusive ranges)

```elixir
alias Bigtable.{ReadRows, RowSet}

ranges = [
  {"Ride#121", "Ride#124"},
  {"Ride#128", "Ride#131"}
]

RowSet.row_ranges(ranges, false)
|> ReadRows.read()
```

#### Custom Table

```elixir
alias Bigtable.{ReadRows, RowSet}

ReadRows.build("projects/[project_id]/instances/[instance_id]/tables/[table_name]")
|> RowSet.row_range("Ride#121", "Ride#124")
|> ReadRows.read()
```

### Filtering Results

```elixir
alias Bigtable.{ReadRows, RowSet}
alias ReadRows.Filter

RowSet.row_keys("Ride#123")
|> Filter.cells_per_column(5)
|> ReadRows.read()
```

## Mutations

### Single Row

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
