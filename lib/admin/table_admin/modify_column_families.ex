defmodule Bigtable.Admin.ModifyColumnFamilies do
  alias Bigtable.Request
  alias Google.Bigtable.Admin.V2.{ColumnFamily, GcRule, ModifyColumnFamiliesRequest}
  alias ModifyColumnFamiliesRequest.Modification

  def build(table_name) when is_binary(table_name) do
    ModifyColumnFamiliesRequest.new(name: table_name)
  end

  def create(%ModifyColumnFamiliesRequest{} = request, column_families) do
    request
    |> build_mods(column_families, :create)
  end

  def update(%ModifyColumnFamiliesRequest{} = request, column_families) do
    request
    |> build_mods(column_families, :update)
  end

  def drop(%ModifyColumnFamiliesRequest{} = request, column_families) do
    mods = Enum.map(column_families, &build_mod(&1, :drop, true))
    apply_mods(request, mods)
  end

  def modify(%ModifyColumnFamiliesRequest{} = request) do
    query = %Bigtable.Query{request: request, type: :modify_column_families, api: :admin}

    query
    |> Request.submit_request()
  end

  defp build_mods(%ModifyColumnFamiliesRequest{} = request, column_families, mod_type) do
    mods =
      for {id, rule} <- column_families do
        cf = ColumnFamily.new(gc_rule: gc_rule(rule))

        build_mod(id, mod_type, cf)
      end

    apply_mods(request, mods)
  end

  defp apply_mods(%ModifyColumnFamiliesRequest{} = request, mods) do
    %{request | modifications: request.modifications ++ mods}
  end

  defp gc_rule(nil), do: GcRule.new()

  defp gc_rule(%GcRule{} = rule), do: rule

  defp build_mod(id, type, rule) do
    Modification.new(id: id, mod: {type, rule})
  end
end
