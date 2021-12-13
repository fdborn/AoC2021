defmodule Aoc2021.Exercises.Day01 do
  alias Aoc2021.Exercise

  defmodule PartOne do
    use Exercise

    @impl true
    def preprocess_input(input) do
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_integer/1)
    end

    @impl true
    def run(input) do
      input
      |> Enum.map_reduce(nil, fn
        depth, acc when is_nil(acc) -> {0, depth}
        depth, acc -> {depth - acc, depth}
      end)
      |> then(&elem(&1, 0))
      |> Enum.filter(&Kernel.>(&1, 0))
      |> length
    end
  end

  defmodule PartTwo do
    use Exercise

    @impl true
    def preprocess_input(input), do: PartOne.preprocess_input(input)

    @impl true
    def run(input) do
      input
      |> Enum.chunk_every(3, 1, :discard)
      |> Enum.map(&Enum.sum/1)
      |> PartOne.run()
    end
  end
end
