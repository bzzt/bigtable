defmodule Bigtable.Connection.Worker do
  @moduledoc false
  use GenServer

  @default_endpoint "bigtable.googleapis.com:443"

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, [])
  end

  def get_connection(pid) do
    GenServer.call(pid, :get_connection)
  end

  def init(_) do
    Process.flag(:trap_exit, true)
    {:ok, nil}
  end

  def handle_call(:get_connection, _from, nil) do
    IO.puts("Starting new connection")

    {:ok, connection} = GRPC.Stub.connect(get_endpoint(), build_opts())

    {:reply, connection, connection}
  end

  def handle_call(:get_connection, _from, state) do
    {:reply, state, state}
  end

  def handle_info({:EXIT, _from, reason}, state) do
    disconnect(state)
    {:stop, reason, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  def terminate(_reason, state) do
    disconnect(state)
    state
  end

  defp disconnect(connection) do
    GRPC.Stub.disconnect(connection)
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
