defmodule Bigtable.SampleRowKeys do
  @moduledoc """
  Provides functionality for building and submitting `Google.Bigtable.V2.SampleRowKeysRequest`.
  """
  alias Bigtable.Request
  alias Google.Bigtable.V2
  alias V2.Bigtable.Stub

  @doc """
  Builds a `Google.Bigtable.V2.SampleRowKeysRequest` given a row_key and optional table name.

  Defaults to configured table name.

  ## Examples

  ### Default Table
      iex> Bigtable.SampleRowKeys.build()
      %Google.Bigtable.V2.SampleRowKeysRequest{
        app_profile_id: "",
        table_name: "projects/dev/instances/dev/tables/test",
      }

  ### Custom Table
      iex> table_name = "projects/project-id/instances/instance-id/tables/table-name"
      iex> Bigtable.SampleRowKeys.build(table_name)
      %Google.Bigtable.V2.SampleRowKeysRequest{
        app_profile_id: "",
        table_name: "projects/project-id/instances/instance-id/tables/table-name",
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
  @spec read(V2.SampleRowKeysRequest.t()) :: {:ok, V2.SampleRowKeysResponse} | {:error, any()}
  def read(%V2.SampleRowKeysRequest{} = request \\ build()) do
    request
    |> Request.process_request(&Stub.sample_row_keys/3, stream: true)
  end
end
