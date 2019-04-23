defmodule ReadModifyWriteRowTest do
  @moduledoc false
  alias Bigtable.Data.{MutateRow, Mutations, ReadModifyWriteRow, ReadRows, RowFilter}
  use ExUnit.Case

  doctest ReadModifyWriteRow

  setup do
    assert ReadRows.read() == {:ok, %{}}

    row_key = "Test#123"

    on_exit(fn ->
      mutation = row_key |> Mutations.build() |> Mutations.delete_from_row()

      mutation |> MutateRow.mutate()
    end)

    [
      family: "cf1",
      row_key: row_key
    ]
  end

  describe "ReadModifyWriteRow.mutate/2" do
    test "should increment an existing numerical value", context do
      qual = "num"
      val = <<1::integer-signed-64>>

      {:ok, _result} =
        context.row_key
        |> Mutations.build()
        |> Mutations.set_cell(context.family, qual, val, 0)
        |> MutateRow.mutate()

      {:ok, _result} =
        context.row_key
        |> ReadModifyWriteRow.build()
        |> ReadModifyWriteRow.increment_amount(context.family, qual, 1)
        |> ReadModifyWriteRow.mutate()

      expected = <<0, 0, 0, 0, 0, 0, 0, 2>>

      {:ok, result} =
        ReadRows.build()
        |> RowFilter.cells_per_column(1)
        |> ReadRows.read()

      new_value = result |> Map.values() |> List.flatten() |> List.first() |> Map.get(:value)

      assert new_value == expected
    end

    test "should increment a non existing column", context do
      qual = "num"

      {:ok, _result} =
        context.row_key
        |> ReadModifyWriteRow.build()
        |> ReadModifyWriteRow.increment_amount(context.family, qual, 3)
        |> ReadModifyWriteRow.mutate()

      expected = <<0, 0, 0, 0, 0, 0, 0, 3>>

      {:ok, result} =
        ReadRows.build()
        |> RowFilter.cells_per_column(1)
        |> ReadRows.read()

      new_value = result |> Map.values() |> List.flatten() |> List.first() |> Map.get(:value)

      assert new_value == expected
    end

    test "should append a string to an existing value", context do
      qual = "string"
      val = "hello"

      {:ok, _result} =
        context.row_key
        |> Mutations.build()
        |> Mutations.set_cell(context.family, qual, val, 0)
        |> MutateRow.mutate()

      {:ok, _result} =
        context.row_key
        |> ReadModifyWriteRow.build()
        |> ReadModifyWriteRow.append_value(context.family, qual, "world")
        |> ReadModifyWriteRow.mutate()

      expected = "helloworld"

      {:ok, result} =
        ReadRows.build()
        |> RowFilter.cells_per_column(1)
        |> ReadRows.read()

      new_value = result |> Map.values() |> List.flatten() |> List.first() |> Map.get(:value)

      assert new_value == expected
    end

    test "should append a string to a non existing column", context do
      qual = "string"

      {:ok, _result} =
        context.row_key
        |> ReadModifyWriteRow.build()
        |> ReadModifyWriteRow.append_value(context.family, qual, "world")
        |> ReadModifyWriteRow.mutate()

      expected = "world"

      {:ok, result} =
        ReadRows.build()
        |> RowFilter.cells_per_column(1)
        |> ReadRows.read()

      new_value = result |> Map.values() |> List.flatten() |> List.first() |> Map.get(:value)

      assert new_value == expected
    end
  end
end
