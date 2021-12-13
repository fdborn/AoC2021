defmodule Aoc2021.Exercises.Day01 do
  alias Aoc2021.Exercise

  defmodule PartOne do
    use Exercise

    exercise "Part 1" do
      preprocess fn input ->
        input
        |> String.split("\n", trim: true)
        |> Enum.map(&String.to_integer/1)
      end

      step "Replace measurement list with deltas", fn input ->
        input
        |> Enum.map_reduce(nil, fn
          depth, acc when is_nil(acc) -> {0, depth}
          depth, acc -> {depth - acc, depth}
        end)
        |> then(&elem(&1, 0))
      end

      step "Remove all measurements less or equal than 0", fn input ->
        input
        |> Enum.filter(&Kernel.>(&1, 0))
      end

      step "Get list length", fn input ->
        input
        |> length()
      end
    end
  end

  defmodule PartTwo do
    use Exercise

    exercise "Part 2" do
      preprocess fn input ->
        input
        |> String.split("\n", trim: true)
        |> Enum.map(&String.to_integer/1)
      end

      step "Split measurements into chunks of size 3, discard overhang", fn input ->
        input
        |> Enum.chunk_every(3, 1, :discard)
      end

      step "Summarize chunks", fn input ->
        input
        |> Enum.map(&Enum.sum/1)
      end

      embed_exercise PartOne
    end

  end
end
