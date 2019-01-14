defmodule ReadRowsTest do
  alias Bigtable.ReadRows

  use ExUnit.Case

  doctest ReadRows

  describe "ReadRows.build() " do
    test "should build a ReadRowsRequest with configured table" do
      assert ReadRows.build() == expected_request()
    end

    test "should build a ReadRowsRequest with custom table" do
      table_name = "custom-table"

      assert ReadRows.build(table_name) == expected_request(table_name)
    end
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
               }
             ]
           }}
      },
      rows: nil,
      rows_limit: 0,
      table_name: table_name
    }
  end
end
