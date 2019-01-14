defmodule RowSetTest do
  alias Bigtable.{ReadRows, RowSet}

  use ExUnit.Case

  doctest(RowSet)

  setup do
    [
      request: %Google.Bigtable.V2.ReadRowsRequest{
        app_profile_id: "",
        filter: %Google.Bigtable.V2.RowFilter{
          filter:
            {:chain,
             %Google.Bigtable.V2.RowFilter.Chain{
               filters: []
             }}
        },
        rows: nil,
        rows_limit: 0,
        table_name: Bigtable.Utils.configured_table_name()
      },
      row_key: "Test#123",
      row_keys: ["Test#123", "Test#124"]
    ]
  end

  describe "RowSet.row_keys()" do
    test "should apply a single row key in a V2.RowSet to a V2.ReadRowsRequest",
         context do
      expected = expected_row_keys(context.row_key)

      result = RowSet.row_keys(context.request, context.row_key)

      assert result.rows == expected
    end

    test "should apply multiple row keys in a V2.RowSet to a V2.ReadRowsRequest",
         context do
      expected = expected_row_keys(context.row_keys)

      result = RowSet.row_keys(context.request, context.row_keys)

      assert result.rows == expected
    end

    test "should apply a row key to the default V2.ReadRowsRequest" do
    end
  end

  defp expected_row_keys(keys) when is_list(keys) do
    %Google.Bigtable.V2.RowSet{row_keys: keys, row_ranges: []}
  end

  defp expected_row_keys(key) do
    expected_row_keys([key])
  end

  defp expected_request(filter) do
    %Google.Bigtable.V2.ReadRowsRequest{
      app_profile_id: "",
      filter: filter,
      rows: nil,
      rows_limit: 0,
      table_name: Bigtable.Utils.configured_table_name()
    }
  end
end
