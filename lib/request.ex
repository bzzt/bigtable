defmodule Bigtable.Request do
  @moduledoc false
  alias Bigtable.{Auth, Connection}
  alias Google.Bigtable.V2.Bigtable.Stub, as: DataStub
  alias Google.Bigtable.Admin.V2.BigtableTableAdmin.Stub, as: AdminStub

  def submit_request(%Bigtable.Query{} = query) do
    Connection
    |> Process.whereis()
    |> DBConnection.execute(query, [])
  end

  def process_request(conn, %Bigtable.Query{} = query) do
    %{request: request, type: type, api: api, opts: opts} = query
    token = Auth.get_token()

    # start = :os.system_time(:millisecond)

    stub =
      if api == :data do
        DataStub
      else
        AdminStub
      end

    # result =
    stub
    |> apply(type, [conn, request, get_metadata(token)])
    |> handle_response(opts)

    # finish = :os.system_time(:millisecond)

    # IO.puts("#{finish - start}ms")
    # result
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
