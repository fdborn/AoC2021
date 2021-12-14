defmodule Aoc2021.Exercise do
  @callback name() :: binary
  @callback run(any) :: any

  defmacro __using__(_) do
    quote do
      @behaviour Aoc2021.Exercise
      import Aoc2021.Exercise.Macros

      defp preprocess_input(input), do: String.split(input, "\n", trim: true)

      defoverridable preprocess_input: 1
    end
  end

  def name(module), do: module.name()
  def run(module, input), do: module.run(input)

  def render(results) do
    Enum.map(results, fn {result, meta} ->
      meta[:renderer].render(result, meta)
    end)
  end

  def wrap_components(rendered_results) do
    Enum.map(rendered_results, fn
      {type, _} = result when type in [:component, :live_component] -> result
      result when is_binary(result) -> plaintext_component(result)
    end)
  end

  defp plaintext_component(text) do
    {:component, &Aoc2021Web.RendererComponents.plaintext/1, %{text: text}}
  end
end
