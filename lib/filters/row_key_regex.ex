defmodule Bigtable.RowFilter.RowKeyRegex do
  @moduledoc false
  alias Bigtable.RowFilter
  alias Bigtable.RowFilter.{Chain, Filter}
  alias Google.Bigtable.V2

  @behaviour Filter

  @impl Filter
  @spec apply_filter(V2.ReadRowsRequest.t(), binary()) :: V2.ReadRowsRequest.t()
  def apply_filter(%V2.ReadRowsRequest{} = request, regex) do
    filter = build_filter(regex)

    filter
    |> Chain.add_to_chain(request)
  end

  @impl Filter
  @spec build_filter(binary()) :: V2.RowFilter.t()
  def build_filter(regex) do
    {:row_key_regex_filter, regex}
    |> RowFilter.build_filter()
  end
end
