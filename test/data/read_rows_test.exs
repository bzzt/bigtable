defmodule ReadRowsTest do
  alias Bigtable.{ChunkReader, MutateRow, MutateRows, Mutations, ReadRows}
  use ExUnit.Case

  doctest ReadRows

  describe "ReadRows.build()" do
    test "should build a ReadRowsRequest with configured table" do
      assert ReadRows.build() == expected_request()
    end

    test "should build a ReadRowsRequest with custom table" do
      table_name = "custom-table"

      assert ReadRows.build(table_name) == expected_request(table_name)
    end
  end

  describe "ReadRows.read()" do
    setup do
      row_keys = ["Test#123", "Test#234"]

      request = Bigtable.ReadRows.build()

      query = %Bigtable.Query{
        opts: [stream: true],
        request: request,
        type: :read_rows
      }

      assert ReadRows.read() == {:ok, query, %{}}

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

      [
        row_keys: row_keys,
        column_family: "cf1",
        column_qualifier: "column",
        value: "value",
        query: query
      ]
    end

    test "should read from an empty table", context do
      assert ReadRows.read() == {:ok, context.query, %{}}
    end

    test "should read from a table with a single record", context do
      [key | _] = context.row_keys

      entry = Mutations.build(key)

      entry
      |> Mutations.set_cell(context.column_family, context.column_qualifier, context.value, 0)
      |> MutateRow.mutate()

      expected = {:ok, context.query, expected_response([key], context)}

      assert ReadRows.read() == expected
    end

    test "should read from a table with multiple records", context do
      entries =
        Enum.map(context.row_keys, fn key ->
          entry = Mutations.build(key)

          entry
          |> Mutations.set_cell(context.column_family, context.column_qualifier, context.value, 0)
        end)

      entries
      |> MutateRows.mutate()

      expected = {:ok, context.query, expected_response(["Test#123", "Test#234"], context)}

      assert ReadRows.read() == expected
    end
  end

  defp expected_response(row_keys, context) do
    for row_key <- row_keys, into: %{} do
      {row_key,
       [
         %ChunkReader.ReadCell{
           family_name: %Google.Protobuf.StringValue{value: context.column_family},
           label: "",
           qualifier: %Google.Protobuf.BytesValue{value: context.column_qualifier},
           row_key: row_key,
           timestamp: 0,
           value: context.value
         }
       ]}
    end
  end

  defp expected_request(table_name \\ Bigtable.Utils.configured_table_name()) do
    %Google.Bigtable.V2.ReadRowsRequest{
      app_profile_id: "",
      filter: nil,
      rows: nil,
      rows_limit: 0,
      table_name: table_name
    }
  end
end
