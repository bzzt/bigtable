defmodule Bigtable.Operations do
  alias Bigtable.Connection
  alias Bigtable.ReadRows
  alias Google.Bigtable.V2

  def mutate_row(%V2.MutateRowRequest{} = request) do
    Connection.get_connection()
    |> Bigtable.Stub.mutate_row(request)
  end

  def read_rows(%V2.ReadRowsRequest{} = request) do
    Connection.get_connection()
    |> Bigtable.Stub.read_rows(request)
  end

  def read_rows() do
    ReadRows.Request.build()
    |> read_rows
  end
end
