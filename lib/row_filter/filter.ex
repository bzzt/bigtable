defmodule Bigtable.RowFilter.Filter do
  @moduledoc """
  Behavior for creating and applying `Google.Bigtable.V2.RowFilter`
  """
  alias Google.Bigtable.V2.RowFilter

  @callback build_filter(any()) :: RowFilter.t()
end
