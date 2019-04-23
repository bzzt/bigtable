defmodule Bigtable.Data.CheckAndMutateRow do
  @moduledoc """
  Provides functions to build `Google.Bigtable.V2.ReadRowsRequest` and submit them to Bigtable.
  """
  alias Bigtable.{Request, Utils}
  alias Google.Bigtable.V2
  alias V2.Bigtable.Stub

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
      iex> table_name = "projects/[project_id]/instances/[instnace_id]/tables/[table_name]"
      iex> Bigtable.Data.CheckAndMutateRow.build(table_name, "Test#123")
      %Google.Bigtable.V2.CheckAndMutateRowRequest{
        app_profile_id: "",
        false_mutations: [],
        predicate_filter: nil,
        row_key: "Test#123",
        table_name: "projects/[project_id]/instances/[instnace_id]/tables/[table_name]",
        true_mutations: []
      }
  """
  @spec build(binary(), binary()) :: V2.CheckAndMutateRowRequest.t()
  def build(table_name \\ Bigtable.Utils.configured_table_name(), row_key)
      when is_binary(table_name) and is_binary(row_key) do
    V2.CheckAndMutateRowRequest.new(table_name: table_name, app_profile_id: "", row_key: row_key)
  end

  @spec predicate(V2.CheckAndMutateRowRequest.t(), V2.RowFilter.t()) ::
          V2.CheckAndMutateRowRequest.t()
  def predicate(%V2.CheckAndMutateRowRequest{} = request, %V2.RowFilter{} = filter) do
    %{request | predicate_filter: filter}
  end

  @spec if_true(V2.CheckAndMutateRowRequest.t(), [V2.Mutation.t()]) ::
          V2.CheckAndMutateRowRequest.t()
  def if_true(%V2.CheckAndMutateRowRequest{} = request, mutations) when is_list(mutations) do
    %{request | true_mutations: extract_mutations(mutations)}
  end

  @spec if_true(V2.CheckAndMutateRowRequest.t(), V2.Mutation.t()) ::
          V2.CheckAndMutateRowRequest.t()
  def if_true(%V2.CheckAndMutateRowRequest{} = request, mutation) do
    if_true(request, [mutation])
  end

  @spec if_false(V2.CheckAndMutateRowRequest.t(), [V2.Mutation.t()]) ::
          V2.CheckAndMutateRowRequest.t()
  def if_false(%V2.CheckAndMutateRowRequest{} = request, mutations) when is_list(mutations) do
    %{request | false_mutations: extract_mutations(mutations)}
  end

  @spec if_false(V2.CheckAndMutateRowRequest.t(), V2.Mutation.t()) ::
          V2.CheckAndMutateRowRequest.t()
  def if_false(%V2.CheckAndMutateRowRequest{} = request, mutation) do
    if_false(request, [mutation])
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

  defp extract_mutations(mutations) do
    mutations
    |> Enum.flat_map(&Map.get(&1, :mutations))
  end
end
