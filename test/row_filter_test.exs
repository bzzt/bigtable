defmodule RowFilterTest do
  alias Bigtable.{ReadRows, RowFilter}

  use ExUnit.Case

  doctest RowFilter

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
      filters: [
        %Google.Bigtable.V2.RowFilter{
          filter: {:cells_per_column_limit_filter, 1}
        },
        %Google.Bigtable.V2.RowFilter{
          filter: {:cells_per_column_limit_filter, 2}
        }
      ],
      filter: %Google.Bigtable.V2.RowFilter{
        filter: {:cells_per_column_limit_filter, 1}
      }
    ]
  end

  describe "RowFilter.chain()" do
    test "should apply a V2.RowFilter.Chain to a V2.ReadRowsRequest given a list of V2.RowFilter",
         context do
      expected = expected_request(context.filters)

      assert RowFilter.chain(context.request, context.filters) == expected
    end

    test "should apply a V2.RowFilter.Chain to a V2.ReadRowsRequest given a V2.RowFilter",
         context do
      expected = expected_request(context.filter)

      assert RowFilter.chain(context.request, context.filter) == expected
    end

    test "should return a V2.RowFilter chain given a list of V2.RowFilter", context do
      expected = expected_chain(context.filters)

      assert RowFilter.chain(context.filters) == expected
    end

    test "should return a V2.RowFilter chain given a V2.RowFilter", context do
      expected = expected_chain(context.filter)

      assert RowFilter.chain(context.filter) == expected
    end
  end

  describe "RowFilter.cells_per_column()" do
    test "should apply a cells per column V2.RowFilter to a V2.ReadRowsRequest", context do
      expected = expected_request(context.filter)

      assert RowFilter.cells_per_column(context.request, 1) == expected
    end

    test "should return a V2.RowFilter given a column limit" do
      column_limit = 5

      expected = %Google.Bigtable.V2.RowFilter{
        filter: {:cells_per_column_limit_filter, column_limit}
      }

      assert RowFilter.cells_per_column(column_limit) == expected
    end
  end

  defp expected_chain(filters) when is_list(filters) do
    %Google.Bigtable.V2.RowFilter{
      filter:
        {:chain,
         %Google.Bigtable.V2.RowFilter.Chain{
           filters: filters
         }}
    }
  end

  defp expected_chain(filter) do
    expected_chain([filter])
  end

  defp expected_request(filters) when is_list(filters) do
    %Google.Bigtable.V2.ReadRowsRequest{
      app_profile_id: "",
      filter: expected_chain(filters),
      rows: nil,
      rows_limit: 0,
      table_name: Bigtable.Utils.configured_table_name()
    }
  end

  defp expected_request(filter) do
    expected_request([filter])
  end
end
