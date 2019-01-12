defmodule Bigtable.RowSet do
  alias Google.Bigtable.V2
  alias Bigtable.ReadRows

  @doc """
  Adds a list of row keys to a ReadRowsRequest
  """
  @spec row_keys(Google.Bigtable.V2.ReadRowsRequest.t(), any()) ::
          Google.Bigtable.V2.ReadRowsRequest.t()
  def row_keys(%V2.ReadRowsRequest{} = request, keys) when is_list(keys) do
    prev_row_ranges = get_row_ranges(request)

    %{request | rows: V2.RowSet.new(row_keys: keys, row_ranges: prev_row_ranges)}
  end

  def row_keys(%V2.ReadRowsRequest{} = request, key) when is_binary(key) do
    row_keys(request, [key])
  end

  @doc """
  Adds a row key to a ReadRowsRequest
  """
  def row_keys(keys) when is_list(keys) do
    ReadRows.build() |> row_keys(keys)
  end

  def row_keys(key) when is_binary(key) do
    ReadRows.build() |> row_keys(key)
  end

  def row_ranges(%V2.ReadRowsRequest{} = request, ranges, inclusive)
      when is_list(ranges) and is_boolean(inclusive) do
    ranges
    |> Enum.map(&translate_range(&1, inclusive))
    |> apply_ranges(request)
  end

  def row_ranges(%V2.ReadRowsRequest{} = request, ranges)
      when is_list(ranges) do
    ranges
    |> Enum.map(&translate_range(&1, true))
    |> apply_ranges(request)
  end

  def row_ranges(ranges, inclusive) when is_list(ranges) and is_boolean(inclusive) do
    ReadRows.build() |> row_ranges(ranges, inclusive)
  end

  def row_ranges(ranges) when is_list(ranges) do
    ReadRows.build() |> row_ranges(ranges, true)
  end

  def row_range(%V2.ReadRowsRequest{} = request, start_key, end_key, inclusive)
      when is_binary(start_key) and is_binary(end_key) and is_boolean(inclusive) do
    range =
      case inclusive do
        false ->
          exclusive_range(start_key, end_key)

        true ->
          inclusive_range(start_key, end_key)
      end

    [range]
    |> apply_ranges(request)
  end

  def row_range(start_key, end_key, inclusive) when is_boolean(inclusive) do
    ReadRows.build |> row_range(start_key, end_key)
  end

  def row_range(%V2.ReadRowsRequest{} = request, start_key, end_key) do
    range = inclusive_range(start_key, end_key)

    [range]
    |> apply_ranges(request)
  end

  def row_range(start_key, end_key) do
    ReadRows.build() |> row_range(start_key, end_key)
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

  defp translate_range({start_key, end_key}, inclusive) do
    case inclusive do
      true -> inclusive_range(start_key, end_key)
      false -> exclusive_range(start_key, end_key)
    end
  end

  defp exclusive_range(start_key, end_key) do
    V2.RowRange.new(
      start_key: {:start_key_open, start_key},
      end_key: {:end_key_open, end_key}
    )
  end

  defp inclusive_range(start_key, end_key) do
    V2.RowRange.new(
      start_key: {:start_key_closed, start_key},
      end_key: {:end_key_closed, end_key}
    )
  end

  defp apply_ranges(ranges, %V2.ReadRowsRequest{} = request) do
    prev_row_keys = get_row_keys(request)

    %{request | rows: V2.RowSet.new(row_keys: prev_row_keys, row_ranges: ranges)}
  end
end
