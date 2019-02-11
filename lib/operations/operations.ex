defmodule Bigtable.Operations do
  @moduledoc false
  alias Bigtable.Connection

  def process_request(request, request_fn, opts \\ []) do
    metadata = Connection.get_metadata()

    connection = Connection.get_connection()

    result =
      connection
      |> request_fn.(request, metadata)

    case result do
      {:ok, stream, _} ->
        processed =
          stream
          |> process_stream()

        if Keyword.get(opts, :single, false) do
          processed
          |> List.first()
        else
          processed
        end

      {:error, error} when is_map(error) ->
        {:error, Map.get(error, :message, "unknown error")}

      _ ->
        {:error, "unknown error"}
    end
  end

  @spec process_stream(Enumerable.t({atom(), resp})) :: [{atom(), resp}] when resp: var
  defp process_stream(stream) do
    stream
    |> Stream.take_while(&remaining_resp?/1)
    |> Enum.to_list()
  end

  defp remaining_resp?({status, _}), do: status != :trailers
end
