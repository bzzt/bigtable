defmodule Bigtable.RowFilter.Filter do
  @moduledoc """
  Behavior for creating and applying `Google.Bigtable.V2.RowFilter`
  """
  alias Google.Bigtable.V2.{ReadRowsRequest, RowFilter}

  @callback apply_filter(ReadRowsRequest.t(), any()) :: ReadRowsRequest.t()
  @callback build_filter(any()) :: RowFilter.t()
end
