defmodule Bigtable.RowFilter do
  alias Google.Bigtable.V2

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
              }
            ]
          }}
      }
  """
  @spec default_chain(V2.ReadRowsRequest.t()) :: V2.ReadRowsRequest.t()
  def default_chain(%V2.ReadRowsRequest{} = request) do
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
              }
            ]
          }}
      }
  """
  @spec default_chain() :: V2.RowFilter.t()
  def default_chain() do
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
  @spec chain(V2.ReadRowsRequest.t(), [V2.RowFilter.t()]) :: V2.ReadRowsRequest.t()
  def chain(%V2.ReadRowsRequest{} = request, filters) when is_list(filters) do
    filter = chain(filters)
    %{request | filter: filter}
  end

  @spec chain(V2.ReadRowsRequest.t(), V2.RowFilter.t()) :: V2.ReadRowsRequest.t()
  def chain(%V2.ReadRowsRequest{} = request, %V2.RowFilter{} = filter) do
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
  @spec chain([V2.RowFilter.t()]) :: V2.RowFilter.t()
  def chain(filters) when is_list(filters) do
    {:chain, V2.RowFilter.Chain.new(filters: filters)}
    |> build_filter()
  end

  @spec chain(V2.RowFilter.t()) :: V2.RowFilter.t()
  def chain(%V2.RowFilter{} = filter) do
    chain([filter])
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
  @spec cells_per_column(V2.ReadRowsRequest.t(), integer()) :: V2.ReadRowsRequest.t()
  def cells_per_column(%V2.ReadRowsRequest{} = request, limit) when is_integer(limit) do
    filter = cells_per_column(limit)

    filter
    |> add_to_chain(request)
  end

  @doc """
  Creates a cells per column `Google.Bigtable.V2.RowFilter`

  ## Examples
      iex> Bigtable.RowFilter.cells_per_column(2)
      %Google.Bigtable.V2.RowFilter{
        filter: {:cells_per_column_limit_filter, 2}
      }
  """
  @spec cells_per_column(integer()) :: V2.RowFilter.t()
  def cells_per_column(limit) when is_integer(limit) do
    {:cells_per_column_limit_filter, limit}
    |> build_filter()
  end

  @spec default_filters() :: list(V2.RowFilter.t())
  defp default_filters() do
    column_filter = cells_per_column(1)
    [column_filter]
  end

  # Adds a filter to a V2.RowFilter.Chain on a V2.ReadRowsRequest
  @spec add_to_chain(V2.RowFilter.t(), V2.ReadRowsRequest.t()) :: V2.ReadRowsRequest.t()
  defp add_to_chain(filter, request) do
    # Fetches the request's previous filter chain
    {:chain, chain} = request.filter.filter

    type = get_filter_type(filter)

    # Ensures only the latest version of each filter is used
    # when filters are applied through piping
    prev_filters =
      chain.filters
      |> remove_duplicates(type)

    # Adds the provided filter to the request's previous chain
    %{request | filter: chain(prev_filters ++ [filter])}
  end

  # Creates a Bigtable.V2.RowFilter given a type and value
  @spec build_filter({atom(), any()}) :: V2.RowFilter.t()
  defp build_filter({type, value}) when is_atom(type) do
    V2.RowFilter.new(filter: {type, value})
  end

  # Removes duplicate filters given a filter type
  @spec remove_duplicates(list(V2.RowFilter.t()), atom()) :: list(V2.RowFilter.t())
  defp remove_duplicates(row_filters, row_filter_type) do
    Enum.filter(row_filters, &(get_filter_type(&1) != row_filter_type))
  end

  # Fetches filter type from filter tuple
  @spec get_filter_type(V2.RowFilter.t()) :: atom()
  defp get_filter_type(%V2.RowFilter{} = filter) do
    elem(filter.filter, 0)
  end
end
