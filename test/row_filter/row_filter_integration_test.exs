defmodule RowFilterIntegration do
  @moduledoc false
  alias Bigtable.{MutateRow, MutateRows, Mutations, ReadRows, RowFilter}

  use ExUnit.Case

  setup do
    assert ReadRows.read() == []

    row_keys = ["Test#1", "Test#2", "Test#3", "Other#1", "Other#2"]

    on_exit(fn ->
      IO.puts("Dropping Rows")

      mutations =
        Enum.map(row_keys, fn key ->
          entry = Mutations.build(key)

          entry
          |> Mutations.delete_from_row()
        end)

      mutations
      |> MutateRows.mutate()
    end)

    [
      row_keys: row_keys
    ]
  end

  describe "RowFilter.cells_per_column" do
    test "should properly limit the number of cells returned" do
      seed_multiple_values()

      [ok: raw] = ReadRows.read()

      IO.inspect(raw)

      assert length(raw.chunks) == 3

      [ok: filtered] =
        ReadRows.build()
        |> RowFilter.cells_per_column(1)
        |> ReadRows.read()

      filtered_value = List.first(filtered.chunks) |> Map.get(:value)

      assert length(filtered.chunks) == 1
      assert filtered_value == "3"
    end
  end

  describe "RowFilter.row_key_regex" do
    test "should properly filter rows based on row key", context do
      seed_values(context)

      rows = ReadRows.read()

      assert length(rows) == length(context.row_keys)

      request = ReadRows.build()

      test_filtered =
        request
        |> RowFilter.row_key_regex("^Test#\\w+")
        |> ReadRows.read()

      other_filtered =
        request
        |> RowFilter.row_key_regex("^Other#\\w+")
        |> ReadRows.read()

      assert length(test_filtered) == 3
      assert length(other_filtered) == 2
    end
  end

  describe "RowFilter.value_regex" do
    test "should properly filter rows based on value", context do
      first_mutation =
        Mutations.build("Test#1")
        |> Mutations.set_cell("cf1", "column", "foo")

      second_mutation =
        Mutations.build("Test#2")
        |> Mutations.set_cell("cf1", "column", "foooo")

      third_mutation =
        Mutations.build("Test#3")
        |> Mutations.set_cell("cf1", "column", "bar")

      {:ok, _} =
        [first_mutation, second_mutation, third_mutation]
        |> MutateRows.build()
        |> MutateRows.mutate()

      result =
        ReadRows.build()
        |> RowFilter.value_regex("foo")
        |> ReadRows.read()

      assert length(result) == 2
    end
  end

  describe "RowFilter.chain" do
    test "should properly apply a chain of filters", context do
      seed_values(context)

      seed_multiple_values()

      filters = [
        RowFilter.row_key_regex("^Test#1"),
        RowFilter.cells_per_column(1)
      ]

      [ok: result] =
        ReadRows.build()
        |> RowFilter.chain(filters)
        |> ReadRows.read()

      assert length(result.chunks) == 1
      assert List.first(result.chunks) |> Map.get(:row_key) == "Test#1"
    end
  end

  defp seed_multiple_values do
    IO.puts("Inserting Rows")

    mutations =
      Enum.map(1..3, fn i ->
        Mutations.build("Test#1")
        |> Mutations.set_cell("cf1", "column", to_string(i), 1000 * i)
      end)

    result =
      mutations
      |> MutateRows.build()
      |> MutateRows.mutate()

    IO.inspect(result)

    IO.puts("Rows Inserted")
  end

  defp seed_values(context) do
    Enum.each(context.row_keys, fn key ->
      {:ok, _} =
        Mutations.build(key)
        |> Mutations.set_cell("cf1", "column", "value")
        |> MutateRow.build()
        |> MutateRow.mutate()
    end)
  end
end