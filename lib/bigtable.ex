defmodule Bigtable do
  @moduledoc """
  Elixir client library for Google Bigtable
  """
  use Application

  @doc false
  def start(_type, _args) do
    children = [
      Bigtable.Supervisor
    ]

    opts = [strategy: :one_for_one, name: Bigtable]
    Supervisor.start_link(children, opts)
  end
end
