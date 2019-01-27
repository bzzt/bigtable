defmodule Bigtable.RowFilter.Filter do
  @moduledoc false
  alias Google.Bigtable.V2.RowFilter

  @callback build_filter(any()) :: RowFilter.t()
end
