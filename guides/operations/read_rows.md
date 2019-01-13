# Read Rows

## All Rows

### Default Table

```elixir
alias Bigtable.ReadRows

ReadRows.read()
```

### Custom Table

```elixir
alias Bigtable.ReadRows

ReadRows.read("projects/[project_id]/instances/[instance_id]/tables/[table_name]")
```

## Single Row Key

### Default Table

```elixir
alias Bigtable.{ReadRows, RowSet}

RowSet.row_keys("Ride#123")
|> ReadRows.read()
```

### Custom Table

```elixir
alias Bigtable.{ReadRows, RowSet}

ReadRows.build("projects/[project_id]/instances/[instance_id]/tables/[table_name]")
|> RowSet.row_keys("Ride#123")
|> ReadRows.read()
```

## Multiple Row Keys

### Default Table

```elixir
alias Bigtable.{ReadRows, RowSet}

RowSet.row_keys(["Ride#123", "Ride#124"])
|> ReadRows.read()
```

### Custom Table

```elixir
alias Bigtable.{ReadRows, RowSet}

ReadRows.build("projects/[project_id]/instances/[instance_id]/tables/[table_name]")
|> RowSet.row_keys(["Ride#123", "Ride#124"])
|> ReadRows.read()
```

## Single Row Range

### Default Table (inclusive range)

```elixir
alias Bigtable.{ReadRows, RowSet}

RowSet.row_range("Ride#121", "Ride#124")
|> ReadRows.read()
```

### Default Table (exclusive range)

```elixir
alias Bigtable.{ReadRows, RowSet}

RowSet.row_range("Ride#121", "Ride#124", false)
|> ReadRows.read()
```

## Multiple Row Ranges

### Default Table (inclusive ranges)

```elixir
alias Bigtable.{ReadRows, RowSet}

ranges = [
  {"Ride#121", "Ride#124"},
  {"Ride#128", "Ride#131"}
]

RowSet.row_ranges(ranges)
|> ReadRows.read()
```

### Default Table (exclusive ranges)

```elixir
alias Bigtable.{ReadRows, RowSet}

ranges = [
  {"Ride#121", "Ride#124"},
  {"Ride#128", "Ride#131"}
]

RowSet.row_ranges(ranges, false)
|> ReadRows.read()
```

### Custom Table

```elixir
alias Bigtable.{ReadRows, RowSet}

ReadRows.build("projects/[project_id]/instances/[instance_id]/tables/[table_name]")
|> RowSet.row_range("Ride#121", "Ride#124")
|> ReadRows.read()
```

## Filtering Results

```elixir
alias Bigtable.{ReadRows, RowSet}
alias ReadRows.Filter

RowSet.row_keys("Ride#123")
|> Filter.cells_per_column(5)
|> ReadRows.read()
```
