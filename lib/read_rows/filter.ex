defmodule Bigtable.ReadRows.Filter do
  alias Google.Bigtable.V2.{RowFilter, ReadRowsRequest}

  def chain(filters) when is_list(filters) do
    {:chain, RowFilter.Chain.new(filters: filters)}
    |> build_filter()
  end

  def cells_per_column(%ReadRowsRequest{} = request, limit) when is_integer(limit) do
    cells_per_column(limit)
    |> add_to_chain(request)
  end

  def cells_per_column(limit) when is_integer(limit) do
    {:cells_per_column_limit_filter, limit}
    |> build_filter()
  end

  defp add_to_chain(filter, request) do
    {:chain, chain} = request.filter.filter
    prev_filters = chain.filters
    %{request | filter: chain(prev_filters ++ [filter])}
  end

  defp build_filter({type, value}) when is_atom(type) do
    %RowFilter{filter: {type, value}}
  end
end
