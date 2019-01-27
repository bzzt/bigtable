defmodule Bigtable.RowFilter.CellsPerColumn do
  @moduledoc false
  alias Bigtable.RowFilter
  alias RowFilter.Filter

  @behaviour Filter

  @impl Filter
  @spec build_filter(integer()) :: Google.Bigtable.V2.RowFilter.t()
  def build_filter(limit) when is_integer(limit) do
    {:cells_per_column_limit_filter, limit}
    |> RowFilter.build_filter()
  end
end
