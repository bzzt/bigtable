defmodule Bigtable.ReadRows.RowSet do
  alias Google.Bigtable.V2

  def row_keys(%V2.ReadRowsRequest{} = request, keys) when is_list(keys) do
    prev_row_ranges = get_row_ranges(request)

    %{request | rows: V2.RowSet.new(row_keys: keys, row_ranges: prev_row_ranges)}
  end

  def row_keys(%V2.ReadRowsRequest{} = request, keys) do
    row_keys(request, [keys])
  end

  def row_ranges(%V2.ReadRowsRequest{} = request, ranges) when is_list(ranges) do
    prev_row_keys = get_row_keys(request)

    %{request | rows: V2.RowSet.new(row_keys: prev_row_keys, row_ranges: ranges)}
  end

  def row_ranges(%V2.ReadRowsRequest{} = request, ranges) do
    row_ranges(request, [ranges])
  end

  defp get_row_ranges(%V2.ReadRowsRequest{} = request) do
    case request.rows do
      %V2.RowSet{} = row_set ->
        row_set.row_ranges

      _ ->
        []
    end
  end

  defp get_row_keys(%V2.ReadRowsRequest{} = request) do
    case request.rows do
      %V2.RowSet{} = row_set ->
        row_set.row_keys

      _ ->
        []
    end
  end
end
