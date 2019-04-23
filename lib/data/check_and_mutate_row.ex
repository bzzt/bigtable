defmodule Bigtable.Data.CheckAndMutateRow do
  @moduledoc """
  Provides functions to build `Google.Bigtable.V2.ReadRowsRequest` and submit them to Bigtable.
  """
  alias Bigtable.{Request, Utils}
  alias Google.Bigtable.V2
  alias V2.Bigtable.Stub

  @type entries() :: V2.MutateRowsRequest.Entry | [V2.MutateRowsRequest.Entry]

  @doc """
  Builds a `Google.Bigtable.V2.CheckAndMutateRowRequest` given a row_key and optional custom table name.

  Defaults to configured table name.

  ## Examples

  ### Default Table
      iex> Bigtable.Data.CheckAndMutateRow.build("Test#123")
      %Google.Bigtable.V2.CheckAndMutateRowRequest{
        app_profile_id: "",
        false_mutations: [],
        predicate_filter: nil,
        row_key: "Test#123",
        table_name: "projects/dev/instances/dev/tables/test",
        true_mutations: []
      }

  ### Custom Table
      iex> table_name = "projects/[project_id]/instances/[instance_id]/tables/[table_name]"
      iex> Bigtable.Data.CheckAndMutateRow.build(table_name, "Test#123")
      %Google.Bigtable.V2.CheckAndMutateRowRequest{
        app_profile_id: "",
        false_mutations: [],
        predicate_filter: nil,
        row_key: "Test#123",
        table_name: "projects/[project_id]/instances/[instance_id]/tables/[table_name]",
        true_mutations: []
      }
  """
  @spec build(binary(), binary()) :: V2.CheckAndMutateRowRequest.t()
  def build(table_name \\ Utils.configured_table_name(), row_key)
      when is_binary(table_name) and is_binary(row_key) do
    V2.CheckAndMutateRowRequest.new(table_name: table_name, app_profile_id: "", row_key: row_key)
  end

  @spec predicate(V2.CheckAndMutateRowRequest.t(), V2.RowFilter.t()) ::
          V2.CheckAndMutateRowRequest.t()
  def predicate(%V2.CheckAndMutateRowRequest{} = request, %V2.RowFilter{} = filter) do
    %{request | predicate_filter: filter}
  end

  @spec if_true(V2.CheckAndMutateRowRequest.t(), entries) :: V2.CheckAndMutateRowRequest.t()
  def if_true(%V2.CheckAndMutateRowRequest{} = request, mutations) do
    %{request | true_mutations: extract_mutations(mutations)}
  end

  @spec if_false(V2.CheckAndMutateRowRequest.t(), entries()) :: V2.CheckAndMutateRowRequest.t()
  def if_false(%V2.CheckAndMutateRowRequest{} = request, mutations) do
    %{request | false_mutations: extract_mutations(mutations)}
  end

  @doc """
  Submits a `Google.Bigtable.V2.CheckAndMutateRowRequest` to Bigtable.
  """
  @spec mutate(V2.CheckAndMutateRowRequest.t()) ::
          {:ok, [V2.CheckAndMutateRowResponse]} | {:error, binary()}
  def mutate(%V2.CheckAndMutateRowRequest{} = request) do
    request
    |> Request.process_request(&Stub.check_and_mutate_row/3, single: true)
  end

  @spec extract_mutations(entries()) :: [V2.Mutation.t()]
  defp extract_mutations(entries) do
    entries
    |> List.wrap()
    |> Enum.flat_map(&Map.get(&1, :mutations))
  end
end
