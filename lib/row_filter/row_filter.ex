defmodule Bigtable.RowFilter do
  alias Bigtable.RowFilter.{CellsPerColumn, Chain, RowKeyRegex}
  alias Google.Bigtable.V2.{ReadRowsRequest, RowFilter}

  @moduledoc """
  Provides functions for creating `Google.Bigtable.V2.RowFilter` and applying them to a `Google.Bigtable.V2.ReadRowsRequest` or `Google.Bigtable.V2.RowFilter.Chain`
  """

  @doc """
  Adds a `Google.Bigtable.V2.RowFilter` chain to a `Google.Bigtable.V2.ReadRowsRequest` given a list of `Google.Bigtable.V2.RowFilter`.

  ## Examples

      iex> filters = [Bigtable.RowFilter.cells_per_column(2), Bigtable.RowFilter.row_key_regex("^Test#\w+")]
      iex> request = Bigtable.ReadRows.build("table") |> Bigtable.RowFilter.chain(filters)
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.filter
      %Google.Bigtable.V2.RowFilter{
        filter: {:chain,
        %Google.Bigtable.V2.RowFilter.Chain{
          filters: [
            %Google.Bigtable.V2.RowFilter{
              filter: {:cells_per_column_limit_filter, 2}
            },
            %Google.Bigtable.V2.RowFilter{
              filter: {:row_key_regex_filter, "^Test#\w+"}
            }
          ]
        }}
      }
  """
  @spec chain(ReadRowsRequest.t(), [RowFilter.t()]) :: ReadRowsRequest.t()
  def chain(%ReadRowsRequest{} = request, filters) when is_list(filters) do
    chain = Chain.build_filter(filters)
    %{request | filter: chain}
  end

  @doc """
  Adds a cells per column `Google.Bigtable.V2.RowFilter` to a `Google.Bigtable.V2.ReadRowsRequest`

  ## Examples
      iex> request = Bigtable.ReadRows.build() |> Bigtable.RowFilter.cells_per_column(2)
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.filter
      %Google.Bigtable.V2.RowFilter{
        filter:  {:cells_per_column_limit_filter, 2}
      }
  """
  @spec cells_per_column(ReadRowsRequest.t(), integer()) :: ReadRowsRequest.t()
  def cells_per_column(%ReadRowsRequest{} = request, limit) when is_integer(limit) do
    filter = cells_per_column(limit)

    filter
    |> apply_filter(request)
  end

  @doc """
  Creates a cells per column `Google.Bigtable.V2.RowFilter`

  ## Examples
      iex> Bigtable.RowFilter.cells_per_column(2)
      %Google.Bigtable.V2.RowFilter{
        filter: {:cells_per_column_limit_filter, 2}
      }
  """
  @spec cells_per_column(integer()) :: RowFilter.t()
  def cells_per_column(limit) when is_integer(limit) do
    CellsPerColumn.build_filter(limit)
  end

  @doc """
  Adds a row key regex `Google.Bigtable.V2.RowFilter` a `Google.Bigtable.V2.ReadRowsRequest`

  ## Examples
      iex> request = Bigtable.ReadRows.build() |> Bigtable.RowFilter.row_key_regex("^Test#\w+")
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.filter
      %Google.Bigtable.V2.RowFilter{
        filter: {:row_key_regex_filter, "^Test#w+"}
      }
  """
  @spec row_key_regex(ReadRowsRequest.t(), binary()) :: ReadRowsRequest.t()
  def row_key_regex(%ReadRowsRequest{} = request, regex) do
    filter = row_key_regex(regex)

    filter
    |> apply_filter(request)
  end

  @doc """
  Creates a row key regex `Google.Bigtable.V2.RowFilter`

  ## Examples
      iex> Bigtable.RowFilter.row_key_regex("^Test#\w+")
      %Google.Bigtable.V2.RowFilter{
        filter: {:row_key_regex_filter, "^Test#\w+"}
      }
  """
  @spec row_key_regex(binary()) :: RowFilter.t()
  def row_key_regex(regex) do
    RowKeyRegex.build_filter(regex)
  end

  # Creates a Bigtable.V2.RowFilter given a type and value
  @spec build_filter({atom(), any()}) :: RowFilter.t()
  def build_filter({type, value}) when is_atom(type) do
    RowFilter.new(filter: {type, value})
  end

  @spec apply_filter(RowFilter.t(), ReadRowsRequest.t()) :: ReadRowsRequest.t()
  defp apply_filter(%RowFilter{} = filter, %ReadRowsRequest{} = request) do
    %{request | filter: filter}
  end
end
