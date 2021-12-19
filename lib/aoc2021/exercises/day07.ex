defmodule Aoc2021.Exercises.Day07 do
  alias Aoc2021.Exercise

  defmodule Part1 do
    use Exercise

    exercise "Part 1" do
      step("Preprocess input", fn input ->
        input
        |> String.trim()
        |> String.split(",", trim: true)
        |> Enum.map(&String.to_integer/1)
      end)

      step("Calculate list middle", fn input ->
        middle_index = floor(length(input) / 2) - 1

        middle =
          input
          |> Enum.sort()
          |> Enum.at(middle_index)

        %{
          positions: input,
          middle: middle
        }
      end)

      step("Calculate fuel consumption", fn input ->
        input.positions
        |> Enum.map(&abs(&1 - input.middle))
        |> Enum.sum()
      end)
    end
  end

  defmodule Part2 do
    use Exercise

    exercise "Part 2" do
      step("Preprocess input", fn input ->
        input
        |> String.trim()
        |> String.split(",", trim: true)
        |> Enum.map(&String.to_integer/1)
      end)

      step("Calculate list mean", fn input ->
        mean =
          input
          |> Enum.sum()
          |> then(&(&1 / length(input)))
          |> floor()

        %{
          positions: input,
          mean: mean,
        }
      end)

      step("Calculate fuel consumption", fn input ->
        input.positions
        |> Enum.map(fn position ->
          distance = abs(position - input.mean)
          triangle_number(distance)
        end)
        |> Enum.sum()
      end)
    end

    defp triangle_number(n), do: (n * n + n) / 2
  end
end
