defmodule Bigtable.Operations.Utils do
  @moduledoc false

  @spec process_stream(Enumerable.t({atom(), resp})) :: [{atom(), resp}] when resp: var
  def process_stream(stream) do
    stream
    |> Stream.take_while(&remaining_resp?/1)
    |> Enum.to_list()
  end

  defp remaining_resp?({status, _}), do: status != :trailers
end
