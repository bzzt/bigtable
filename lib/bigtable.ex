defmodule Bigtable do
  use Application

  def start(_type, _args) do
    children = [
      Bigtable.Supervisor
    ]

    opts = [strategy: :one_for_one, name: Bigtable]
    Supervisor.start_link(children, opts)
  end
end
