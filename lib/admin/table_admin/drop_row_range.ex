defmodule Bigtable.Admin.DropRowRange do
  alias Bigtable.Request
  alias Google.Bigtable.Admin.V2.DropRowRangeRequest

  @spec build(binary()) :: DropRowRangeRequest.t()
  def build(table_name) do
    DropRowRangeRequest.new(name: table_name)
  end

  @spec row_key_prefix(DropRowRangeRequest.t(), binary()) :: DropRowRangeRequest.t()
  def row_key_prefix(%DropRowRangeRequest{} = request, prefix) do
    %{request | target: {:row_key_prefix, prefix}}
  end

  @spec delete_all_data(DropRowRangeRequest.t()) :: DropRowRangeRequest.t()
  def delete_all_data(%DropRowRangeRequest{} = request) do
    %{request | target: {:delete_all_data_from_table, true}}
  end

  def drop(%DropRowRangeRequest{} = request) do
    query = %Bigtable.Query{request: request, type: :drop_row_range, api: :admin}

    query
    |> Request.submit_request()
  end
end
