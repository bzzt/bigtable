defmodule Bigtable do
  @moduledoc """
  Elixir client library for Google Bigtable
  """
  use Application

  @doc false
  def start(_type, _args) do
    default_opts = [
      {:name, {:local, :connection_pool}},
      {:worker_module, Bigtable.Connection.Worker},
      {:size, 20},
      {:max_overflow, 40}
    ]

    opts = Keyword.merge(default_opts, Application.get_env(:bigtable, :connection_pool))

    IO.inspect(opts)

    children = [
      Bigtable.Supervisor,
      :poolboy.child_spec(:connection_pool, opts, [])
    ]

    opts = [strategy: :one_for_one, name: Bigtable]
    Supervisor.start_link(children, opts)
  end
end
