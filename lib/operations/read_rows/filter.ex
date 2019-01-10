defmodule Bigtable.ReadRows.Filter do
  alias Google.Bigtable.V2.{RowFilter, ReadRowsRequest}

  @doc """
  Creates a RowFilter chain given a list of Bigtable.V2.RowFilter
  """
  @spec chain(maybe_improper_list()) :: Google.Bigtable.V2.RowFilter.t()
  def chain(filters) when is_list(filters) do
    {:chain, RowFilter.Chain.new(filters: filters)}
    |> build_filter()
  end

  @doc """
  Adds a cells per column filter to an existing RowFilter chain
  """
  @spec cells_per_column(Google.Bigtable.V2.ReadRowsRequest.t(), integer()) ::
          Google.Bigtable.V2.ReadRowsRequest.t()
  def cells_per_column(%ReadRowsRequest{} = request, limit) when is_integer(limit) do
    cells_per_column(limit)
    |> add_to_chain(request)
  end

  @doc """
  Filters row columns to return only the latest N cells per column
  """
  @spec cells_per_column(integer()) :: %{:__struct__ => atom(), optional(atom()) => any()}
  def cells_per_column(limit) when is_integer(limit) do
    {:cells_per_column_limit_filter, limit}
    |> build_filter()
  end

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
  defp build_filter({type, value}) when is_atom(type) do
    RowFilter.new(filter: {type, value})
  end

  # Removes duplicate filters given a filter type
  defp remove_duplicates(row_filters, row_filter_type) do
    Enum.filter(row_filters, &(get_filter_type(&1) != row_filter_type))
  end

  # Fetches filter type from filter tuple
  defp get_filter_type(%RowFilter{} = filter) do
    elem(filter.filter, 0)
  end
end
