defmodule Bigtable.ReadModifyWriteRow do
  @moduledoc """
  Provides functions to build `Google.Bigtable.V2.ReadModifyWriteRowRequest` and submit them to Bigtable.
  """
  alias Bigtable.Utils
  alias Google.Bigtable.V2
  alias V2.Bigtable.Stub

  alias Google.Bigtable.V2.{
    ReadModifyWriteRowRequest,
    ReadModifyWriteRowResponse,
    ReadModifyWriteRule
  }

  @doc """
  Builds a `Google.Bigtable.V2.ReadModifyWriteRowRequest` with a provided table name and row key`.
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

  @spec mutate(ReadModifyWriteRowRequest.t()) ::
          {:ok, ReadModifyWriteRowResponse.t()} | {:error, binary()}
  def mutate(%ReadModifyWriteRowRequest{} = request) do
    request
    |> Utils.process_request(&Stub.read_modify_write_row/3, single: true)
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
