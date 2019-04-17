defmodule Bigtable.Utils do
  @moduledoc false

  alias Bigtable.Connection
  alias Connection.Worker

  def process_request(request, request_fn, opts \\ []) do
    result = GenServer.call(
      Bigtable.Request.Producer,
      {:add_request, {request, request_fn}}
      10_000
    )

    case result do
      {:ok, response, _} ->
        if Keyword.get(opts, :stream, false) do
          processed =
            response
            |> process_stream()

          {:ok, processed}
        else
          {:ok, response}
        end

      {:error, error} ->
        {:error, inspect(error)}

      error ->
        {:error, inspect(error)}
    end
  end

  def configured_table_name do
    project = get_project()
    instance = get_instance()
    table = Application.get_env(:bigtable, :table)

    "projects/#{project}/instances/#{instance}/tables/#{table}"
  end

  def configured_instance_name do
    project = get_project()
    instance = get_instance()
    "projects/#{project}/instances/#{instance}"
  end

  defp get_project() do
    Application.get_env(:bigtable, :project)
  end

  defp get_instance() do
    Application.get_env(:bigtable, :instance)
  end

  @spec process_stream(Enumerable.t()) :: [{atom(), any}]
  defp process_stream(stream) do
    stream
    |> Stream.take_while(&remaining_resp?/1)
    |> Enum.to_list()
  end

  defp remaining_resp?({status, _}), do: status != :trailers
end
