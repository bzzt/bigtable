defmodule BigtableTest do
  use ExUnit.Case
  doctest Bigtable

  test "greets the world" do
    assert Bigtable.hello() == :world
  end
end
