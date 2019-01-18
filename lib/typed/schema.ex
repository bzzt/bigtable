defmodule Bigtable.Schema do
  defmacro __using__(_opt) do
    quote do
      import unquote(__MODULE__)
    end
  end

  defmacro type(do: block) do
    columns =
      case block do
        {:__block__, [], multiple} -> multiple
        {:column, _, [name, block]} -> [{:column, [], [name, block]}]
      end

    column_list = list_from_block(columns, :column)

    quote do
      defstruct unquote(column_list)

      def type() do
        %__MODULE__{}
      end
    end
  end

  defmacro row(do: block) do
    families =
      case block do
        {:__block__, [], multiple} -> multiple
        {:family, _, [name, block]} -> [{:family, [], [name, block]}]
      end

    family_list = list_from_block(families, :family)

    families_with_columns =
      Enum.map(family_list, fn family ->
        {family_name, [do: {:__block__, [], columns}]} = family
        column_list = list_from_block(columns, :column)

        {family_name, Map.new(column_list)}
      end)

    quote do
      defstruct unquote(Macro.escape(families_with_columns))

      def parse(row) do
        Bigtable.Typed.parse_typed(__MODULE__.type(), row)
      end

      def type() do
        %__MODULE__{}
      end
    end
  end

  defmacro family(name, do: block), do: {name, block}

  defmacro column(key, value), do: {key, value}

  defp list_from_block(block, to_match) do
    Enum.reduce(block, [], fn value, accum ->
      with {block_type, _, [k, v]} <- value do
        case block_type == to_match do
          true -> [{k, get_value_type(v)} | accum]
          false -> accum
        end
      end
    end)
  end

  defp get_value_type(value) when is_atom(value), do: value

  defp get_value_type({:__aliases__, _, modules}) do
    Module.concat([Elixir | modules]).type()
  end

  defp get_value_type(value) do
    value
  end
end
