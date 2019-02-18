# defmodule Google.Bigtable.Admin.V2.GcRule do
#   @moduledoc false
#   use Protobuf, syntax: :proto3

#   @type t :: %__MODULE__{
#           rule: {atom, any}
#         }
#   defstruct [:rule]

#   oneof :rule, 0
#   field :max_num_versions, 1, type: :int32, oneof: 0
#   field :max_age, 2, type: Google.Protobuf.Duration, oneof: 0
#   field :intersection, 3, type: Google.Bigtable.Admin.V2.GcRule.Intersection, oneof: 0
#   field :union, 4, type: Google.Bigtable.Admin.V2.GcRule.Union, oneof: 0
# end
defmodule Bigtable.Admin.GcRule do
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
