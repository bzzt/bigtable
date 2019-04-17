defmodule Bigtable.Request.Consumer do
  use ConsumerSupervisor

  def start_link(arg) do
    ConsumerSupervisor.start_link(__MODULE__, arg)
  end

  def init(_arg) do
    children = [
      %{
        id: Bigtable.Request.Worker,
        start: {Bigtable.Request.Worker, :start_link, []},
        restart: :transient
      }
    ]

    opts = [
      strategy: :one_for_one,
      subscribe_to: [{Bigtable.Request.Producer, min_demand: 100, max_demand: 128}]
    ]

    ConsumerSupervisor.init(children, opts)
  end
end
