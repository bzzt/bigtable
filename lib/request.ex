defmodule Bigtable.Request do
  @moduledoc false
  alias Bigtable.{Auth, Connection}
  alias Connection.Worker

  @spec process_request(any(), function(), list()) :: {:ok, any()} | {:error, any()}
  def process_request(request, request_fn, opts \\ []) do
    response =
      :poolboy.transaction(
        :connection_pool,
        fn pid ->
          token = Auth.get_token()

          pid
          |> Worker.get_connection()
          |> request_fn.(request, get_metadata(token))
        end,
        10_000
      )

    handle_response(response, opts)
  end

  @spec handle_response(any(), list()) :: {:ok, any()} | {:error, any()}
  defp handle_response({:ok, response, _headers}, opts) do
    if Keyword.get(opts, :stream, false) do
      response
      |> process_stream()
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

  @spec process_stream(Enumerable.t()) :: [{:ok | :error, any}]
  defp process_stream(stream) do
    result =
      stream
      |> Stream.take_while(&remaining_resp?/1)
      |> Enum.to_list()

    if Enum.any?(result, fn {status, _} -> status == :error end) do
      {:error, "Stream error"}
    else
      {:ok, result}
    end
  end

  @spec remaining_resp?({:ok | :error | :trailers, any()}) :: boolean()
  defp remaining_resp?({status, _}), do: status == :ok

  @spec get_metadata(map()) :: Keyword.t()
  defp get_metadata(%{token: token}) do
    metadata = %{authorization: "Bearer #{token}"}
    [metadata: metadata, content_type: "application/grpc", return_headers: true]
  end
end
