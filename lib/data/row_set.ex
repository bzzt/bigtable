defmodule Bigtable.RowSet do
  @moduledoc """
  Provides functions to build a `Google.Bigtable.V2.RowSet` and apply it to a `Google.Bigtable.V2.ReadRowsRequest`
  """
  alias Bigtable.ReadRows
  alias Google.Bigtable.V2

  @doc """
  Adds a single or list of row keys to a `Google.Bigtable.V2.ReadRowsRequest`

  Returns `Google.Bigtable.V2.ReadRowsRequest`

  ## Examples
  #### Single Key

      iex> request = Bigtable.ReadRows.build("table") |> Bigtable.RowSet.row_keys("Row#123")
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.rows
      %Google.Bigtable.V2.RowSet{row_keys: ["Row#123"], row_ranges: []}

  #### Multiple Keys
      iex> request = Bigtable.ReadRows.build("table") |> Bigtable.RowSet.row_keys(["Row#123", "Row#124"])
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.rows
      %Google.Bigtable.V2.RowSet{row_keys: ["Row#123", "Row#124"], row_ranges: []}
  """
  @spec row_keys(V2.ReadRowsRequest.t(), [binary()]) :: V2.ReadRowsRequest.t()
  def row_keys(%V2.ReadRowsRequest{} = request, keys) when is_list(keys) do
    prev_row_ranges = get_row_ranges(request)

    %{request | rows: V2.RowSet.new(row_keys: keys, row_ranges: prev_row_ranges)}
  end

  @spec row_keys(V2.ReadRowsRequest.t(), binary()) :: V2.ReadRowsRequest.t()
  def row_keys(%V2.ReadRowsRequest{} = request, key) when is_binary(key) do
    row_keys(request, [key])
  end

  @doc """
  Adds a single or list of row keys to the default `Google.Bigtable.V2.ReadRowsRequest`

  Returns `Google.Bigtable.V2.ReadRowsRequest`

  ## Examples
  #### Single Key

      iex> request = Bigtable.RowSet.row_keys("Row#123")
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.rows
      %Google.Bigtable.V2.RowSet{row_keys: ["Row#123"], row_ranges: []}

  #### Multiple Keys
      iex> request = Bigtable.RowSet.row_keys(["Row#123", "Row#124"])
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.rows
      %Google.Bigtable.V2.RowSet{row_keys: ["Row#123", "Row#124"], row_ranges: []}
  """
  @spec row_keys([binary()]) :: V2.ReadRowsRequest.t()
  def row_keys(keys) when is_list(keys) do
    ReadRows.build() |> row_keys(keys)
  end

  @spec row_keys(binary()) :: V2.ReadRowsRequest.t()
  def row_keys(key) when is_binary(key) do
    ReadRows.build() |> row_keys(key)
  end

  @doc """
  Adds a single or list of row ranges to a `Google.Bigtable.V2.ReadRowsRequest` with an optional boolean flag to specify the inclusivity of the range start and end.

  Row ranges should be provided in the format {start, end} or {start, end, inclusive}.

  Returns `Google.Bigtable.V2.ReadRowsRequest`

  ## Examples
  #### Single Range

      iex> request = Bigtable.ReadRows.build("table") |> Bigtable.RowSet.row_ranges({"start", "end"})
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.rows
      %Google.Bigtable.V2.RowSet{
        row_keys: [],
        row_ranges: [
          %Google.Bigtable.V2.RowRange{
            end_key: {:end_key_closed, "end"},
            start_key: {:start_key_closed, "start"}
          }
        ]
      }

  #### Multiple Ranges

      iex> ranges = [{"start1", "end1"}, {"start2", "end2", false}]
      iex> request = Bigtable.ReadRows.build("table") |> Bigtable.RowSet.row_ranges(ranges)
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.rows
      %Google.Bigtable.V2.RowSet{
        row_keys: [],
        row_ranges: [
            %Google.Bigtable.V2.RowRange{
            end_key: {:end_key_closed, "end1"},
            start_key: {:start_key_closed, "start1"}
          },
          %Google.Bigtable.V2.RowRange{
            end_key: {:end_key_open, "end2"},
            start_key: {:start_key_open, "start2"}
          }
        ]
      }
  """

  @spec row_ranges(
          V2.ReadRowsRequest.t(),
          [{binary(), binary(), binary()}]
          | [{binary(), binary()}]
          | {binary(), binary(), binary()}
          | {binary(), binary()}
        ) :: V2.ReadRowsRequest.t()
  def row_ranges(%V2.ReadRowsRequest{} = request, ranges) do
    ranges = List.flatten([ranges])

    ranges
    |> Enum.map(&translate_range/1)
    |> apply_ranges(request)
  end

  @doc """
  Adds a single or list of row ranges to the default `Google.Bigtable.V2.ReadRowsRequest` with an optional boolean flag to specify the inclusivity of the range start and end.

  Row ranges should be provided in the format {start, end} or {start, end, inclusive}.

  Returns `Google.Bigtable.V2.ReadRowsRequest`

  ## Examples
  #### Single Range

      iex> request = Bigtable.RowSet.row_ranges({"start", "end"})
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.rows
      %Google.Bigtable.V2.RowSet{
        row_keys: [],
        row_ranges: [
          %Google.Bigtable.V2.RowRange{
            end_key: {:end_key_closed, "end"},
            start_key: {:start_key_closed, "start"}
          }
        ]
      }

  #### Multiple Ranges

      iex> ranges = [{"start1", "end1"}, {"start2", "end2", false}]
      iex> request = Bigtable.RowSet.row_ranges(ranges)
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.rows
      %Google.Bigtable.V2.RowSet{
        row_keys: [],
        row_ranges: [
            %Google.Bigtable.V2.RowRange{
            end_key: {:end_key_closed, "end1"},
            start_key: {:start_key_closed, "start1"}
          },
          %Google.Bigtable.V2.RowRange{
            end_key: {:end_key_open, "end2"},
            start_key: {:start_key_open, "start2"}
          }
        ]
      }
  """

  @spec row_ranges(
          [{binary(), binary(), binary()}]
          | [{binary(), binary()}]
          | [{binary(), binary(), binary()}]
          | {binary(), binary(), binary()}
        ) :: V2.ReadRowsRequest.t()
  def row_ranges(ranges) do
    ReadRows.build()
    |> row_ranges(ranges)
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

  # Returns an inclusive or exclusive range depending on the boolean flag

  defp translate_range({start_key, end_key, inclusive}) do
    case inclusive do
      true -> inclusive_range(start_key, end_key)
      false -> exclusive_range(start_key, end_key)
    end
  end

  defp translate_range({start_key, end_key}) do
    inclusive_range(start_key, end_key)
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

  # Applies row ranges to a ReadRows request
  defp apply_ranges(ranges, %V2.ReadRowsRequest{} = request) do
    prev_row_keys = get_row_keys(request)

    %{request | rows: V2.RowSet.new(row_keys: prev_row_keys, row_ranges: ranges)}
  end
end
