defmodule Bigtable do
  @moduledoc """
  Elixir client library for Google Bigtable
  """
  use Application

  @doc false
  def start(_type, _args) do
    poolboy_config = [
      {:name, {:local, :connection_pool}},
      {:worker_module, Bigtable.Connection.Worker},
      {:size, Application.get_env(:bigtable, :pool_size, 128)},
      {:max_overflow, Application.get_env(:bigtable, :pool_overflow, 0)}
    ]

    children = [
      Bigtable.Supervisor,
      :poolboy.child_spec(:connection_pool, poolboy_config, [])
    ]

    opts = [strategy: :one_for_one, name: Bigtable]
    Supervisor.start_link(children, opts)
  end
end
