defmodule Bigtable.RowFilter.Chain do
  @moduledoc false
  alias Bigtable.RowFilter
  alias Google.Bigtable.V2
  alias RowFilter.Filter
  alias V2.RowFilter.Chain

  @behaviour Filter

  @impl Filter
  @spec apply_filter(V2.ReadRowsRequest.t(), [V2.RowFilter.t()]) :: V2.ReadRowsRequest.t()
  def apply_filter(%V2.ReadRowsRequest{} = request, filters) when is_list(filters) do
    filter = build_filter(filters)
    %{request | filter: filter}
  end

  @impl Filter
  @spec apply_filter(V2.ReadRowsRequest.t(), V2.RowFilter.t()) :: V2.ReadRowsRequest.t()
  def apply_filter(%V2.ReadRowsRequest{} = request, %V2.RowFilter{} = filter) do
    apply_filter(request, [filter])
  end

  @impl Filter
  @spec build_filter([V2.RowFilter.t()]) :: V2.RowFilter.t()
  def build_filter(filters) when is_list(filters) do
    {:chain, Chain.new(filters: filters)}
    |> RowFilter.build_filter()
  end

  @impl Filter
  @spec build_filter(V2.RowFilter.t()) :: V2.RowFilter.t()
  def build_filter(%V2.RowFilter{} = filter) do
    build_filter([filter])
  end

  # Adds a filter to a V2.RowFilter.Chain on a V2.ReadRowsRequest
  @spec add_to_chain(V2.RowFilter.t(), V2.ReadRowsRequest.t()) :: V2.ReadRowsRequest.t()
  def add_to_chain(filter, request) do
    # Fetches the request's previous filter chain
    {:chain, chain} = request.filter.filter

    type = get_filter_type(filter)

    # Ensures only the latest version of each filter is used
    # when filters are applied through piping
    prev_filters =
      chain.filters
      |> remove_duplicates(type)

    # Adds the provided filter to the request's previous chain
    %{request | filter: build_filter(prev_filters ++ [filter])}
  end

  @spec get_filter_type(V2.RowFilter.t()) :: atom()
  defp get_filter_type(%V2.RowFilter{} = filter) do
    elem(filter.filter, 0)
  end

  # Removes duplicate filters given a filter type
  @spec remove_duplicates([V2.RowFilter.t()], atom()) :: [V2.RowFilter.t()]
  defp remove_duplicates(row_filters, row_filter_type) do
    Enum.filter(row_filters, &(get_filter_type(&1) != row_filter_type))
  end
end
