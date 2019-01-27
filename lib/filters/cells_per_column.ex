defmodule Bigtable.RowFilter.CellsPerColumn do
  @moduledoc false
  alias Bigtable.RowFilter
  alias Google.Bigtable.V2.ReadRowsRequest
  alias RowFilter.{Chain, Filter}

  @behaviour Filter

  @impl Filter
  @spec apply_filter(ReadRowsRequest.t(), integer()) :: ReadRowsRequest.t()
  def apply_filter(%ReadRowsRequest{} = request, limit) when is_integer(limit) do
    filter = build_filter(limit)

    filter
    |> Chain.add_to_chain(request)
  end

  @impl Filter
  @spec build_filter(integer()) :: Google.Bigtable.V2.RowFilter.t()
  def build_filter(limit) when is_integer(limit) do
    {:cells_per_column_limit_filter, limit}
    |> RowFilter.build_filter()
  end
end
