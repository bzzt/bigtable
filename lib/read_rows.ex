defmodule Bigtable.ReadRows do
  alias Google.Bigtable.V2
  alias Bigtable.RowFilter
  alias Bigtable.Connection

  @doc """
  Builds a `Google.Bigtable.V2.ReadRowsRequest` with a provided table name.

  ## Examples
      iex> request = Bigtable.ReadRows.build("table")
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: request.table_name
      "table"
  """
  @spec build(binary()) :: V2.ReadRowsRequest.t()
  def build(table_name) when is_binary(table_name) do
    V2.ReadRowsRequest.new(table_name: table_name)
    |> RowFilter.default_chain()
  end

  @doc """
  Builds a `Google.Bigtable.V2.ReadRowsRequest` with the configured table name.
   ## Examples
      iex> request = Bigtable.ReadRows.build()
      iex> with %Google.Bigtable.V2.ReadRowsRequest{} <- request, do: :ok
      :ok
  """
  @spec build() :: V2.ReadRowsRequest.t()
  def build() do
    build(Bigtable.Utils.configured_table_name())
  end

  @doc """
  Submits a `Google.Bigtable.V2.ReadRowsRequest` to Bigtable.

  Returns a list of `{:ok, %Google.Bigtable.V2.ReadRowsResponse{}}`.
  """
  @spec read(V2.ReadRowsRequest.t()) :: {:ok, V2.ReadRowsResponse.t()}
  def read(%V2.ReadRowsRequest{} = request) do
    {:ok, rows} =
      Connection.get_connection()
      |> Bigtable.Stub.read_rows(request)

    rows
    |> Enum.filter(fn {status, row} ->
      status == :ok and !Enum.empty?(row.chunks)
    end)
  end

  @doc """
  Builds a `Google.Bigtable.V2.ReadRowsRequest` with a provided table name and submits it to Bigtable.

  Returns a list of `{:ok, %Google.Bigtable.V2.ReadRowsResponse{}}`.
  """
  @spec read(binary()) :: {:ok, V2.ReadRowsResponse.t()}
  def read(table_name) when is_binary(table_name) do
    build(table_name)
    |> read()
  end

  @doc """
  Builds a `Google.Bigtable.V2.ReadRowsRequest` with the configured table name and submits it to Bigtable.

  Returns a list of `{:ok, %Google.Bigtable.V2.ReadRowsResponse{}}`.
  """
  @spec read() :: {:ok, V2.ReadRowsResponse.t()}
  def read() do
    build()
    |> read
  end
end
