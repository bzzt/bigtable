defmodule Bigtable.Operations do
  alias Bigtable.Connection
  alias Bigtable.ReadRows
  alias Google.Bigtable.V2

  def mutate(%V2.MutateRowRequest{} = request) do
    Connection.get_connection()
    |> Bigtable.Stub.mutate_row(request)
  end

  def mutate(%V2.MutateRowsRequest{} = request) do
    Connection.get_connection()
    |> Bigtable.Stub.mutate_rows(request)
  end
end
