defmodule RowFilterIntegration do
  @moduledoc false
  alias Bigtable.{MutateRow, MutateRows, Mutations, ReadRows, RowFilter}

  use ExUnit.Case

  describe "RowFilter.cells_per_column" do
    setup do
      assert ReadRows.read() == []

      row_keys = ["Test#123", "Test#124", "Test#125"]

      on_exit(fn ->
        mutations =
          Enum.map(row_keys, fn key ->
            entry = Mutations.build(key)

            entry
            |> Mutations.delete_from_row()
          end)

        mutations
        |> MutateRows.mutate()
      end)
    end

    test "should properly limit the number of cells returned" do
      for i <- 1..3 do
        Mutations.build("Test#123")
        |> Mutations.set_cell("cf1", "column", to_string(i))
        |> MutateRow.build()
        |> MutateRow.mutate()
      end

      [ok: raw] = ReadRows.read()

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
end
