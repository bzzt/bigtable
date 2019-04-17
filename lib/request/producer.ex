defmodule Bigtable.Request.Producer do
  use GenStage

  def start_link(arg) do
    GenStage.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    {:producer, {:queue.new(), 0}}
  end

  def handle_call({:add_request, request}, from, {queue, pending_demand}) do
    queue = :queue.in({request, from}, queue)

    {requests, state} = dispatch_requests(queue, pending_demand, [])
    {:noreply, [requests], state}
  end

  def handle_demand(incoming_demand, {queue, pending_demand}) do
    {requests, state} = dispatch_requests(queue, incoming_demand + pending_demand, [])

    {:noreply, requests, state}
  end

  defp dispatch_requests(queue, 0, requests) do
    {Enum.reverse(requests), {queue, 0}}
  end

  defp dispatch_requests(queue, demand, requests) do
    case :queue.out(queue) do
      {{:value, request}, queue} ->
        dispatch_requests(queue, demand - 1, [request | requests])

      {:empty, queue} ->
        {Enum.reverse(requests), {queue, demand}}
    end
  end
end
