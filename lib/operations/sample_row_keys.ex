defmodule Bigtable.SampleRowKeys do
  @moduledoc """
  Provides functions to build `Google.Bigtable.V2.SampleRowKeysRequest` and submit them to Bigtable.
  """
  alias Bigtable.Connection
  alias Bigtable.Operations.Utils
  alias Google.Bigtable.V2

  @doc """
  Builds a `Google.Bigtable.V2.SampleRowKeysRequest` given a row_key and optional custom table name.

  Defaults to configured table name.

  ## Examples

  ### Default Table
      iex> Bigtable.SampleRowKeys.build()
      %Google.Bigtable.V2.SampleRowKeysRequest{
        app_profile_id: "",
        table_name: "projects/dev/instances/dev/tables/test",
      }

  ### Custom Table
      iex> table_name = "projects/[project_id]/instances/[instance_id]/tables/[table_name]"
      iex> Bigtable.SampleRowKeys.build(table_name)
      %Google.Bigtable.V2.SampleRowKeysRequest{
        app_profile_id: "",
        table_name: "projects/[project_id]/instances/[instance_id]/tables/[table_name]",
      }
  """
  @spec build(binary()) :: V2.SampleRowKeysRequest.t()
  def build(table_name \\ Bigtable.Utils.configured_table_name())
      when is_binary(table_name) do
    V2.SampleRowKeysRequest.new(table_name: table_name, app_profile_id: "")
  end

  @doc """
  Submits a `Google.Bigtable.V2.SampleRowKeysRequest` to Bigtable.
  """
  @spec read(V2.SampleRowKeysRequest.t()) ::
          [{:ok, V2.SampleRowKeysResponse} | {:error, any()}] | {:error, binary()}
  def read(%V2.SampleRowKeysRequest{} = request) do
    metadata = Connection.get_metadata()

    connection = Connection.get_connection()

    result =
      connection
      |> Bigtable.Stub.sample_row_keys(request, metadata)

    case result do
      {:ok, stream, _} ->
        stream
        |> Utils.process_stream()

      {:error, error} when is_map(error) ->
        {:error, Map.get(error, :message, "unknown error")}

      _ ->
        {:error, "unknown error"}
    end
  end

  @spec read() :: [{:ok, V2.SampleRowKeysResponse} | {:error, any()}] | {:error, binary()}
  def read() do
    build()
    |> read()
  end
end
