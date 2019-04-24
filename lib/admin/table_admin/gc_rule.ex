defmodule Bigtable.Admin.GcRule do
  @moduledoc """
  Provides functions for creating garbage collection rules
  """
  alias Google.Bigtable.Admin.V2
  alias Google.Protobuf.Duration
  alias V2.GcRule.{Intersection, Union}

  def max_num_versions(limit) when is_integer(limit) do
    V2.GcRule.new(rule: {:max_num_versions, limit})
  end

  def max_age(milliseconds) do
    duration = build_duration(milliseconds)
    V2.GcRule.new(rule: {:max_age, duration})
  end

  def intersection(rules) when is_list(rules) do
    V2.GcRule.new(rule: {:intersection, Intersection.new(rules: rules)})
  end

  def union(rules) when is_list(rules) do
    V2.GcRule.new(rule: {:union, Union.new(rules: rules)})
  end

  defp build_duration(milliseconds) do
    {seconds, remainder} =
      ~w|div rem|a
      |> Enum.map(&apply(Kernel, &1, [milliseconds, 1000]))
      |> List.to_tuple()

    Duration.new(
      seconds: seconds,
      nanos: remainder * 1_000_000
    )
  end
end
