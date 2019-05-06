defmodule Bigtable.Protocol do
  use DBConnection
  @default_endpoint "bigtable.googleapis.com:443"

  def connect(opts) do
    IO.puts("INSIDE CONNECT")

    opts = build_opts()

    {:ok, connection} =
      GRPC.Stub.connect(
        get_endpoint(),
        opts ++ [adapter_opts: %{http2_opts: %{keepalive: :infinity}}]
      )

    {:ok, connection}
  end

  def disconnect(err, connection) do
    IO.puts("INSIDE DISCONNECT")
    GRPC.Stub.disconnect(connection)
    :ok
  end

  def checkin(state) do
    {:ok, state}
  end

  def checkout(state) do
    {:ok, state}
  end

  def ping(state) do
    {:ok, state}
  end

  def handle_begin(opts, state) do
    {:ok, %{}, state}
  end

  def handle_close(query, opts, state) do
    {:ok, %{}, state}
  end

  def handle_commit(opts, state) do
    {:ok, %{}, state}
  end

  def handle_declare(query, params, opts, state) do
    {:ok, query, %{}, state}
  end

  def handle_deallocate(query, cursor, opts, state) do
    {:ok, %{}, state}
  end

  def handle_fetch(query, cursor, opts, state) do
    {:ok, query, %{}, state}
  end

  def handle_prepare(query, opts, state) do
    {:ok, query, state}
  end

  def handle_rollback(opts, state) do
    {:ok, %{}, state}
  end

  def handle_status(opts, state) do
    IO.inspect(opts)
    {:idle, state}
  end

  def handle_execute(query, _params, _opts, conn) do
    response =
      conn
      |> Bigtable.Request.process_request(query)

    case response do
      {:ok, response} ->
        {:ok, query, response, conn}

      {:error, error} ->
        {:error, error, conn}
    end
  end

  @spec build_opts() :: list()
  defp build_opts do
    if Application.get_env(:bigtable, :ssl, true) do
      [
        cred: %GRPC.Credential{
          ssl: []
        }
      ]
    else
      []
    end
  end

  @spec get_endpoint() :: binary()
  defp get_endpoint do
    emulator = System.get_env("BIGTABLE_EMULATOR_HOST")
    endpoint = Application.get_env(:bigtable, :endpoint, @default_endpoint)

    if emulator != nil do
      emulator
    else
      endpoint
    end
  end
end
