defmodule Bigtable.Data.ReadModifyWriteRow do
  @moduledoc """
  Provides functionality for building and submitting a `Google.Bigtable.V2.ReadModifyWriteRowRequest`.
  """
  alias Bigtable.Request
  alias Google.Bigtable.V2
  alias V2.Bigtable.Stub

  alias Google.Bigtable.V2.{
    ReadModifyWriteRowRequest,
    ReadModifyWriteRowResponse,
    ReadModifyWriteRule
  }

  @type response :: {:ok, ReadModifyWriteRowResponse.t()} | {:error, binary()}

  @doc """
  Builds a `Google.Bigtable.V2.ReadModifyWriteRowRequest` given a row key and optional table name.
  """
  @spec build(binary(), binary()) :: ReadModifyWriteRowRequest.t()
  def build(table_name \\ Bigtable.Utils.configured_table_name(), row_key)
      when is_binary(table_name) and is_binary(row_key) do
    ReadModifyWriteRowRequest.new(table_name: table_name, app_profile_id: "", row_key: row_key)
  end

  @spec append_value(
          Google.Bigtable.V2.ReadModifyWriteRowRequest.t(),
          binary(),
          binary(),
          binary()
        ) :: Google.Bigtable.V2.ReadModifyWriteRowRequest.t()
  def append_value(%ReadModifyWriteRowRequest{} = request, family_name, column_qualifier, value)
      when is_binary(family_name) and is_binary(column_qualifier) and is_binary(value) do
    ReadModifyWriteRule.new(
      family_name: family_name,
      column_qualifier: column_qualifier,
      rule: {:append_value, value}
    )
    |> add_rule(request)
  end

  @spec increment_amount(
          Google.Bigtable.V2.ReadModifyWriteRowRequest.t(),
          binary(),
          binary(),
          integer()
        ) :: Google.Bigtable.V2.ReadModifyWriteRowRequest.t()
  def increment_amount(
        %ReadModifyWriteRowRequest{} = request,
        family_name,
        column_qualifier,
        amount
      )
      when is_binary(family_name) and is_binary(column_qualifier) and is_integer(amount) do
    ReadModifyWriteRule.new(
      family_name: family_name,
      column_qualifier: column_qualifier,
      rule: {:increment_amount, amount}
    )
    |> add_rule(request)
  end

  @spec mutate(ReadModifyWriteRowRequest.t()) :: response()
  def mutate(%ReadModifyWriteRowRequest{} = request) do
    request
    |> Request.process_request(&Stub.read_modify_write_row/3, single: true)
  end

  @spec add_rule(ReadModifyWriteRule.t(), ReadModifyWriteRowRequest.t()) ::
          ReadModifyWriteRowRequest.t()
  defp add_rule(rule, %ReadModifyWriteRowRequest{} = request) do
    %{
      request
      | rules: Enum.reverse([rule | request.rules])
    }
  end
end
