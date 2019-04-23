defmodule Bigtable.Request do
  alias Bigtable.Connection
  alias Connection.Worker

  def process_request(request, request_fn, opts \\ []) do
    response =
      :poolboy.transaction(
        :connection_pool,
        fn pid ->
          connection = Worker.get_connection(pid)
          metadata = Connection.get_metadata()

          connection
          |> request_fn.(request, metadata)
        end,
        10_000
      )

    handle_response(response, opts)
  end

  defp handle_response({:ok, response, _headers}, opts) do
    if Keyword.get(opts, :stream, false) do
      processed =
        response
        |> process_stream()

      {:ok, processed}
    else
      {:ok, response}
    end
  end

  defp handle_response(error, _opts) do
    case error do
      {:error, _msg} ->
        error

      msg ->
        {:error, msg}
    end
  end

  @spec process_stream(Enumerable.t()) :: [{atom(), any}]
  defp process_stream(stream) do
    stream
    |> Stream.take_while(&remaining_resp?/1)
    |> Enum.to_list()
  end

  defp remaining_resp?({status, _}), do: status != :trailers
end
