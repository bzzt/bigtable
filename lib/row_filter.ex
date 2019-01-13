defmodule Bigtable.RowFilter do
  alias Google.Bigtable.V2

  @doc """
  Adds a RowFilter chain to a ReadRowsRequest given a list of Bigtable.V2.RowFilter
  """
  @spec chain(V2.ReadRowsRequest.t(), list(V2.RowFilter.t())) :: V2.ReadRowsRequest.t()
  def chain(%V2.ReadRowsRequest{} = request, filters) when is_list(filters) do
    filter = chain(filters)
    %{request | filter: filter}
  end

  @doc """
  Creates a V2.RowFilter chain given a list of V2.RowFilter
  """
  @spec chain(list(V2.RowFilter.t())) :: V2.RowFilter.t()
  def chain(filters) when is_list(filters) do
    {:chain, V2.RowFilter.Chain.new(filters: filters)}
    |> build_filter()
  end

  @doc """
  Adds a cells per column V2.RowFilter to an existing V2.ReadRowsRequest V2.RowFilter.Chain
  """
  @spec cells_per_column(V2.ReadRowsRequest.t(), integer()) :: V2.ReadRowsRequest.t()
  def cells_per_column(%V2.ReadRowsRequest{} = request, limit) when is_integer(limit) do
    cells_per_column(limit)
    |> add_to_chain(request)
  end

  @doc """
  Creates a cells per column V2.RowFilter
  """
  @spec cells_per_column(integer()) :: V2.RowFilter.t()
  def cells_per_column(limit) when is_integer(limit) do
    {:cells_per_column_limit_filter, limit}
    |> build_filter()
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
