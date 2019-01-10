defmodule Bigtable.ReadRows do
  alias Bigtable.Connection
  alias Bigtable.ReadRows.Request
  alias Google.Bigtable.V2

  def read(%V2.ReadRowsRequest{} = request) do
    Connection.get_connection()
    |> Bigtable.Stub.read_rows(request)
  end

  def read(_) do
    read(Request.build())
  end

  def read() do
    read(Request.build())
  end
end
