defmodule Bigtable.RowSet do
  alias Google.Bigtable.V2

  @doc """
  Adds a list of row keys to a ReadRowsRequest
  """
  @spec row_keys(Google.Bigtable.V2.ReadRowsRequest.t(), any()) ::
          Google.Bigtable.V2.ReadRowsRequest.t()
  def row_keys(%V2.ReadRowsRequest{} = request, keys) when is_list(keys) do
    prev_row_ranges = get_row_ranges(request)

    %{request | rows: V2.RowSet.new(row_keys: keys, row_ranges: prev_row_ranges)}
  end

  @doc """
  Adds a row key to a ReadRowsRequest
  """
  def row_keys(%V2.ReadRowsRequest{} = request, keys) do
    row_keys(request, [keys])
  end

  @doc """
  Adds a list of row ranges to a ReadRowsRequest
  """
  @spec row_ranges(Google.Bigtable.V2.ReadRowsRequest.t(), any()) ::
          Google.Bigtable.V2.ReadRowsRequest.t()
  def row_ranges(%V2.ReadRowsRequest{} = request, ranges) when is_list(ranges) do
    prev_row_keys = get_row_keys(request)

    %{request | rows: V2.RowSet.new(row_keys: prev_row_keys, row_ranges: ranges)}
  end

  @doc """
  Adds a row range to ReadRowsRequest
  """
  def row_ranges(%V2.ReadRowsRequest{} = request, ranges) do
    row_ranges(request, [ranges])
  end

  # Fetches the previous row ranges from a ReadRowsRequest object
  defp get_row_ranges(%V2.ReadRowsRequest{} = request) do
    case request.rows do
      %V2.RowSet{} = row_set ->
        row_set.row_ranges

      _ ->
        []
    end
  end

  # Fetches the previous row keys from a ReadRowsRequest object
  defp get_row_keys(%V2.ReadRowsRequest{} = request) do
    case request.rows do
      %V2.RowSet{} = row_set ->
        row_set.row_keys

      _ ->
        []
    end
  end
end
