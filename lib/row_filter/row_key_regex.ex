defmodule Bigtable.RowFilter.RowKeyRegex do
  @moduledoc false
  alias Bigtable.RowFilter
  alias Bigtable.RowFilter.Filter

  @behaviour Filter

  @impl Filter
  @spec build_filter(binary()) :: Google.Bigtable.V2.RowFilter.t()
  def build_filter(regex) do
    {:row_key_regex_filter, regex}
    |> RowFilter.build_filter()
  end
end
