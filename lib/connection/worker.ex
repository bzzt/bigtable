defmodule Bigtable.Connection.Worker do
  @moduledoc false
  alias Bigtable.Connection
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, [])
  end

  def get_connection(pid) do
    GenServer.call(pid, :get_connection)
  end

  def init(_) do
    Process.flag(:trap_exit, true)
    {:ok, Connection.connect()}
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
    Connection.disconnect(connection)
  end
end
