defmodule Bigtable.RowFilter.Chain do
  @moduledoc false
  alias Bigtable.RowFilter
  alias Google.Bigtable.V2
  alias RowFilter.Filter
  alias V2.RowFilter.Chain

  @behaviour Filter

  @impl Filter
  @spec build_filter([V2.RowFilter.t()]) :: V2.RowFilter.t()
  def build_filter(filters) when is_list(filters) do
    {:chain, Chain.new(filters: filters)}
    |> RowFilter.build_filter()
  end
end
