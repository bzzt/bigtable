defmodule Acceptance do
  defmacro __using__(json: json) do
    tests =
      File.read!(json)
      |> Poison.decode!()
      |> Map.get("tests")

    Enum.map(tests, fn t ->
      quote do
        test unquote(t["name"]) do
          t = unquote(Macro.escape(t))

          Enum.map(t["chunks"], fn c ->
            Google.Bigtable.V2.ReadRowsResponse.CellChunk.(c)
          end)
        end
      end
    end)
  end
end

defmodule ReadRowAcceptanceTest do
  use ExUnit.Case

  use Acceptance, json: "test/operations/read-rows-acceptance.json"

  # defmacro acceptance(tests) do
  #   IO.inspect(tests)
  # end

  # tests =
  #   File.read!("test/operations/read-rows-acceptance.json")
  #   |> Poison.decode!()
  #   |> Map.get("tests")

  # Acceptance.generate_tests()

  # Enum.map(tests, fn t ->
  #   ExUnit.Case.register_test(__ENV__, :acceptance, t["name"], [])
  # end)
end
