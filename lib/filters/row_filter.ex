defmodule Bigtable.RowFilter do
  alias Bigtable.RowFilter.{CellsPerColumn, Chain, RowKeyRegex}
  alias Google.Bigtable.V2.{ReadRowsRequest, RowFilter}

  @moduledoc """
  Provides functions for creating `Google.Bigtable.V2.RowFilter` and applying them to `Google.Bigtable.V2.RowFilter.Chain`
  """

  @doc """
  Applies the default `Google.Bigtable.V2.RowFilter` to a `Google.Bigtable.V2.ReadRowsRequest`.

  Used internally by `Bigtable.ReadRows.build/0` and `Bigtable.ReadRows.build/1`.

  ## Examples

      iex> request = Bigtable.ReadRows.build() |> Bigtable.RowSet.row_keys("Row#123")
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.filter
      %Google.Bigtable.V2.RowFilter{
        filter: {:chain,
          %Google.Bigtable.V2.RowFilter.Chain{
            filters: [
              %Google.Bigtable.V2.RowFilter{
                filter: {:cells_per_column_limit_filter, 1}
              },
              %Google.Bigtable.V2.RowFilter{
                filter: {:cells_per_column_limit_filter, 1}
              }
            ]
          }}
      }
  """
  @spec default_chain(ReadRowsRequest.t()) :: ReadRowsRequest.t()
  def default_chain(%ReadRowsRequest{} = request) do
    filters = default_filters()
    chain(request, filters)
  end

  @doc """
  Returns the default `Google.Bigtable.V2.RowFilter` used by this module.

  ## Examples

      iex> Bigtable.RowFilter.default_chain()
      %Google.Bigtable.V2.RowFilter{
        filter: {:chain,
          %Google.Bigtable.V2.RowFilter.Chain{
            filters: [
              %Google.Bigtable.V2.RowFilter{
                filter: {:cells_per_column_limit_filter, 1}
              },
              %Google.Bigtable.V2.RowFilter{
                filter: {:cells_per_column_limit_filter, 1}
              }
            ]
          }}
      }
  """
  @spec default_chain() :: RowFilter.t()
  def default_chain do
    default_filters()
    |> chain()
  end

  @doc """
  Adds a `Google.Bigtable.V2.RowFilter` chain to a `Google.Bigtable.V2.ReadRowsRequest` given a single or  list of `Google.Bigtable.V2.RowFilter`.

  ## Examples

  #### Single Filter

      iex> filter = Bigtable.RowFilter.cells_per_column(2)
      iex> request = Bigtable.ReadRows.build("table") |> Bigtable.RowFilter.chain(filter)
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.filter
      %Google.Bigtable.V2.RowFilter{
        filter: {:chain,
        %Google.Bigtable.V2.RowFilter.Chain{
          filters: [
            %Google.Bigtable.V2.RowFilter{
              filter: {:cells_per_column_limit_filter, 2}
            }
          ]
        }}
      }

  #### Multiple Filters

      iex> filters = [Bigtable.RowFilter.cells_per_column(2), Bigtable.RowFilter.cells_per_column(3)]
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
              filter: {:cells_per_column_limit_filter, 3}
            }
          ]
        }}
      }
  """
  @spec chain(ReadRowsRequest.t(), [RowFilter.t()]) :: ReadRowsRequest.t()
  def chain(%ReadRowsRequest{} = request, filters) when is_list(filters) do
    filter = chain(filters)
    %{request | filter: filter}
  end

  @spec chain(ReadRowsRequest.t(), RowFilter.t()) :: ReadRowsRequest.t()
  def chain(%ReadRowsRequest{} = request, %RowFilter{} = filter) do
    chain(request, [filter])
  end

  @doc """
  Creates a `Google.Bigtable.V2.RowFilter` chain given a single or list of `Google.Bigtable.V2.RowFilter`.

  ## Examples

  #### Single Filter
      iex> filter = Bigtable.RowFilter.cells_per_column(2)
      iex> Bigtable.RowFilter.chain(filter)
      %Google.Bigtable.V2.RowFilter{
        filter: {:chain,
        %Google.Bigtable.V2.RowFilter.Chain{
          filters: [
            %Google.Bigtable.V2.RowFilter{
              filter: {:cells_per_column_limit_filter, 2}
            }
          ]
        }}
      }

  #### Multiple Filters
      iex> filters = [Bigtable.RowFilter.cells_per_column(2), Bigtable.RowFilter.cells_per_column(3)]
      iex> Bigtable.RowFilter.chain(filters)
      %Google.Bigtable.V2.RowFilter{
        filter: {:chain,
        %Google.Bigtable.V2.RowFilter.Chain{
          filters: [
            %Google.Bigtable.V2.RowFilter{
              filter: {:cells_per_column_limit_filter, 2}
            },
            %Google.Bigtable.V2.RowFilter{
              filter: {:cells_per_column_limit_filter, 3}
            }
          ]
        }}
      }
  """
  @spec chain([RowFilter.t()]) :: RowFilter.t()
  def chain(filters) when is_list(filters) do
    Chain.build_filter(filters)
  end

  @spec chain(RowFilter.t()) :: RowFilter.t()
  def chain(%RowFilter{} = filter) do
    Chain.build_filter(filter)
  end

  @doc """
  Adds a cells per column `Google.Bigtable.V2.RowFilter` to an existing `Google.Bigtable.V2.RowFilter` chain on a `Google.Bigtable.V2.ReadRowsRequest`

  ## Examples
      iex> request = Bigtable.ReadRows.build() |> Bigtable.RowFilter.cells_per_column(2)
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.filter
      %Google.Bigtable.V2.RowFilter{
        filter: {:chain,
        %Google.Bigtable.V2.RowFilter.Chain{
          filters: [
            %Google.Bigtable.V2.RowFilter{
              filter: {:cells_per_column_limit_filter, 2}
            }
          ]
        }}
      }
  """
  @spec cells_per_column(ReadRowsRequest.t(), integer()) :: ReadRowsRequest.t()
  def cells_per_column(%ReadRowsRequest{} = request, limit) when is_integer(limit) do
    CellsPerColumn.apply_filter(request, limit)
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
  Adds a row key regex `Google.Bigtable.V2.RowFilter` to an existing `Google.Bigtable.V2.RowFilter` chain on a `Google.Bigtable.V2.ReadRowsRequest`

  ## Examples
      iex> request = Bigtable.ReadRows.build() |> Bigtable.RowFilter.row_key_regex("^Test#\w+")
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.filter
      %Google.Bigtable.V2.RowFilter{
        filter: {
          :chain,
          %Google.Bigtable.V2.RowFilter.Chain{
            filters: [
              %Google.Bigtable.V2.RowFilter{
                filter: {:cells_per_column_limit_filter, 1}
              },
              %Google.Bigtable.V2.RowFilter{
                filter: {:cells_per_column_limit_filter, 1}
              },
              %Google.Bigtable.V2.RowFilter{
                filter: {:row_key_regex_filter, "^Test#w+"}
              }
            ]
          }
        }
      }
  """
  @spec row_key_regex(ReadRowsRequest.t(), binary()) :: ReadRowsRequest.t()
  def row_key_regex(%ReadRowsRequest{} = request, regex) do
    RowKeyRegex.apply_filter(request, regex)
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

  @spec default_filters() :: list(RowFilter.t())
  defp default_filters do
    column_filter = cells_per_column(1)
    [column_filter, column_filter]
  end
end
