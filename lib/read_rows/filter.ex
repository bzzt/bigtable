defmodule Bigtable.ReadRows.Filter do
  alias Google.Bigtable.V2.RowFilter

  def cells_per_column(limit) when is_integer(limit) do
    %RowFilter{filter: {:cells_per_column_limit_filter, limit}}
  end
end
