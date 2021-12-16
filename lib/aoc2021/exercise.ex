defmodule Aoc2021.Exercise do
  @callback name() :: binary
  @callback run(any) :: any

  defmacro __using__(_) do
    quote do
      @behaviour Aoc2021.Exercise
      import Aoc2021.Exercise.Macros
    end
  end

  def name(module), do: module.name()
  def run(module, input), do: module.run(input)

  def render(results) do
    Enum.map(results, fn {result, meta} ->
      {component, view_data} = meta[:renderer].render(result, meta)

      meta =
        meta
        |> Keyword.merge(Map.to_list(view_data))

      {component, meta}
    end)
  end

end
