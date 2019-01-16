defmodule Bigtable.ReadRows do
  @moduledoc """
  Provides functions to build `Google.Bigtable.V2.ReadRowsRequest` and submit them to Bigtable.
  """

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
    V2.ReadRowsRequest.new(table_name: table_name, app_profile_id: "default")
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
    {:ok, token} =
      [
        "https://www.googleapis.com/auth/bigtable.data",
        "https://www.googleapis.com/auth/bigtable.data.readonly",
        "https://www.googleapis.com/auth/cloud-bigtable.data",
        "https://www.googleapis.com/auth/cloud-bigtable.data.readonly",
        "https://www.googleapis.com/auth/cloud-platform",
        "https://www.googleapis.com/auth/cloud-platform.read-only",
        "https://www.googleapis.com/auth/bigtable.admin",
        "https://www.googleapis.com/auth/bigtable.admin.cluster",
        "https://www.googleapis.com/auth/bigtable.admin.instance",
        "https://www.googleapis.com/auth/bigtable.admin.table",
        "https://www.googleapis.com/auth/cloud-bigtable.admin",
        "https://www.googleapis.com/auth/cloud-bigtable.admin.cluster",
        "https://www.googleapis.com/auth/cloud-bigtable.admin.table"
      ]
      |> Enum.join(" ")
      |> Goth.Token.for_scope()

    metadata = %{authorization: "Bearer #{token.token}"}

    {:ok, rows} =
      Connection.get_connection()
      |> Bigtable.Stub.read_rows(request, metadata: metadata, content_type: "application/grpc")

    Enum.map(rows, &IO.inspect(&1))

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
    request = build(table_name)

    request
    |> read()
  end

  @doc """
  Builds a `Google.Bigtable.V2.ReadRowsRequest` with the configured table name and submits it to Bigtable.

  Returns a list of `{:ok, %Google.Bigtable.V2.ReadRowsResponse{}}`.
  """
  @spec read() :: {:ok, V2.ReadRowsResponse.t()}
  def read() do
    request = build()

    request
    |> read
  end
end
