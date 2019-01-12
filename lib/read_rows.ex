defmodule Bigtable.ReadRows do
  alias Google.Bigtable.V2
  alias Bigtable.RowFilter
  alias Bigtable.Connection

  @doc """
  Builds a ReadRows request with a provided table name
  """
  @spec build(binary()) :: Google.Bigtable.V2.ReadRowsRequest.t()
  def build(table_name) when is_binary(table_name) do
    V2.ReadRowsRequest.new(table_name: table_name)
    |> default_filters()
  end

  @doc """
  Builds a ReadRows request with default table name if none provided
  """
  def build() do
    build(Bigtable.Utils.configured_table_name())
  end

  def read(%V2.ReadRowsRequest{} = request) do
    {:ok, rows} =
      Connection.get_connection()
      |> Bigtable.Stub.read_rows(request)

    rows
    |> Enum.filter(fn {status, row} ->
      status == :ok and !Enum.empty?(row.chunks)
    end)
  end

  def read(table_name) when is_binary(table_name) do
    build(table_name)
    |> read()
  end

  def read() do
    build()
    |> read
  end

  @doc """
  Applies a RowFilter to a given ReadRowsRequest
  """
  @spec filter_rows(Google.Bigtable.V2.ReadRowsRequest.t(), Google.Bigtable.V2.RowFilter.t()) ::
          Google.Bigtable.V2.ReadRowsRequest.t()
  def filter_rows(%V2.ReadRowsRequest{} = request, %V2.RowFilter{} = filter) do
    %{request | filter: filter}
  end

  # Applies default filter of only the most recent cell per column
  defp default_filters(%V2.ReadRowsRequest{} = request) do
    column_filter = RowFilter.cells_per_column(1)
    default_chain = RowFilter.chain([column_filter])
    request |> filter_rows(default_chain)
  end
end
