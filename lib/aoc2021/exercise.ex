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

  def run(module, input), do: module.run(input)
  def name(module), do: module.name()
end
