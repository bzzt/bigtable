defmodule Bigtable.Request.Worker do
  alias Bigtable.Connection

  def start_link([{request, from}]) do
    Task.start_link(fn ->
      result = send_request(request)
      GenServer.reply(from, result)
    end)
  end

  def start_link({request, from}) do
    Task.start_link(fn ->
      result = send_request(request)
      GenServer.reply(from, result)
    end)
  end

  def start_link([]) do
    Task.start_link(fn -> nil end)
  end

  defp send_request({request, request_fn}) do
    :poolboy.transaction(
      :connection_pool,
      fn pid ->
        connection = Connection.Worker.get_connection(pid)
        metadata = Connection.get_metadata()

        connection
        |> request_fn.(request, metadata)
      end,
      10_000
    )
  end
end
