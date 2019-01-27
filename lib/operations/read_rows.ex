defmodule Bigtable.ReadRows do
  @moduledoc """
  Provides functions to build `Google.Bigtable.V2.ReadRowsRequest` and submit them to Bigtable.
  """

  alias Bigtable.Connection
  alias Google.Bigtable.V2

  @doc """
  Builds a `Google.Bigtable.V2.ReadRowsRequest` with a provided table name.

  ## Examples
      iex> table_name = "projects/[project_id]/instances/[instnace_id]/tables/[table_name]"
      iex> Bigtable.ReadRows.build(table_name)
      %Google.Bigtable.V2.ReadRowsRequest{
        app_profile_id: "",
        filter: nil,
        rows: nil,
        rows_limit: 0,
        table_name: "projects/[project_id]/instances/[instnace_id]/tables/[table_name]"
      }
  """
  @spec build(binary()) :: V2.ReadRowsRequest.t()
  def build(table_name) when is_binary(table_name) do
    V2.ReadRowsRequest.new(table_name: table_name, app_profile_id: "")
  end

  @doc """
  Builds a `Google.Bigtable.V2.ReadRowsRequest` with the configured table name.

  ## Examples
      iex> Bigtable.ReadRows.build()
      %Google.Bigtable.V2.ReadRowsRequest{
        app_profile_id: "",
        filter: nil,
        rows: nil,
        rows_limit: 0,
        table_name: "projects/dev/instances/dev/tables/test"
      }
  """
  @spec build() :: V2.ReadRowsRequest.t()
  def build do
    build(Bigtable.Utils.configured_table_name())
  end

  @doc """
  Submits a `Google.Bigtable.V2.ReadRowsRequest` to Bigtable.

  Can be called with either a `Google.Bigtable.V2.ReadRowsRequest` or a table name to read all rows from a non-configured table.

  Returns a list of `{:ok, %Google.Bigtable.V2.ReadRowsResponse{}}`.
  """
  @spec read(V2.ReadRowsRequest.t()) ::
          {:error, GRPC.RPCError.t()}
          | [ok: V2.ReadRowsResponse.t()]
  def read(%V2.ReadRowsRequest{} = request) do
    metadata = Connection.get_metadata()

    {:ok, rows} =
      Connection.get_connection()
      |> Bigtable.Stub.read_rows(request, metadata)

    rows
    |> Enum.filter(fn {status, row} ->
      status == :ok and !Enum.empty?(row.chunks)
    end)
  end

  @spec read(binary()) ::
          {:error, GRPC.RPCError.t()}
          | [ok: V2.ReadRowsResponse.t()]
  def read(table_name) when is_binary(table_name) do
    request = build(table_name)

    request
    |> read()
  end

  @doc """
  Submits a `Google.Bigtable.V2.ReadRowsRequest` to Bigtable.

  Without arguments, `Bigtable.ReadRows.read` will read all rows from the configured table.

  Returns a list of `{:ok, %Google.Bigtable.V2.ReadRowsResponse{}}`.
  """
  @spec read() ::
          {:error, GRPC.RPCError.t()}
          | [ok: V2.ReadRowsResponse.t()]
  def read do
    request = build()

    request
    |> read
  end
end
