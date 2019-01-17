defmodule Bigtable.TypedMacro do
  defmacro __using__(_opt) do
    quote do
      import unquote(__MODULE__), only: :macros
    end
  end

  defmacro typed(do: block) do
    {_, _, fields} = block

    field_list =
      Keyword.new(
        Enum.map(fields, fn field ->
          {_, _, [key, value]} = field
          {key, value}
        end)
      )

    quote do
      defstruct unquote(field_list)
    end
  end

  defmacro field(key, value) do
    IO.inspect(key)
    IO.inspect(value)
  end
end

defmodule ChildType do
  use Bigtable.TypedMacro

  typed do
    field(:a, :integer)
    field(:b, :integer)
  end
end

defmodule ParentType do
  use Bigtable.TypedMacro

  typed do
    field(:first, :integer)
    field(:second, :boolean)
    field(:child, %ChildType{})
  end
end
