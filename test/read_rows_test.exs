defmodule ReadRowsTest do
  alias Bigtable.{MutateRow, MutateRows, Mutations, ReadRows}

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
      assert ReadRows.read() == []

      row_keys = ["Test#123", "Test#234"]

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
        value: "value"
      ]
    end

    test "should read from an empty table" do
      assert ReadRows.read() == []
    end

    test "should read from a table with a single record", context do
      [key | _] = context.row_keys

      entry = Mutations.build(key)

      entry
      |> Mutations.set_cell(context.column_family, context.column_qualifier, context.value, 0)
      |> MutateRow.mutate()

      expected = [
        ok: expected_response(key, context)
      ]

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

      expected = [
        ok: expected_response("Test#123", context),
        ok: expected_response("Test#234", context)
      ]

      assert ReadRows.read() == expected
    end
  end

  defp expected_response(row_key, context) do
    %Google.Bigtable.V2.ReadRowsResponse{
      chunks: [
        %Google.Bigtable.V2.ReadRowsResponse.CellChunk{
          family_name: %Google.Protobuf.StringValue{value: context.column_family},
          labels: [],
          qualifier: %Google.Protobuf.BytesValue{value: context.column_qualifier},
          row_key: row_key,
          row_status: {:commit_row, true},
          timestamp_micros: 0,
          value: context.value,
          value_size: 0
        }
      ],
      last_scanned_row_key: ""
    }
  end

  defp expected_request(table_name \\ Bigtable.Utils.configured_table_name()) do
    %Google.Bigtable.V2.ReadRowsRequest{
      app_profile_id: "",
      filter: %Google.Bigtable.V2.RowFilter{
        filter:
          {:chain,
           %Google.Bigtable.V2.RowFilter.Chain{
             filters: [
               %Google.Bigtable.V2.RowFilter{
                 filter: {:cells_per_column_limit_filter, 1}
               },
               %Google.Bigtable.V2.RowFilter{filter: {:cells_per_column_limit_filter, 1}}
             ]
           }}
      },
      rows: nil,
      rows_limit: 0,
      table_name: table_name
    }
  end
end
