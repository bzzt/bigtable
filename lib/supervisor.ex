defmodule Bigtable.Supervisor do
  @moduledoc false
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      Bigtable.Connection,
      Bigtable.Request.Producer,
      Bigtable.Request.Consumer,
      {DynamicSupervisor, name: Bigtable.ChunkReader.Supervisor, strategy: :one_for_one}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
