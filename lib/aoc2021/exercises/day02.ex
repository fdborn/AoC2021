defmodule Aoc2021.Exercises.Day02 do
  alias Aoc2021.Exercise

  defmodule Part1 do
    use Exercise

    exercise "Part 1" do
      preprocess(fn input ->
        input
        |> String.split("\n", trim: true)
        |> Enum.map(fn
          "forward " <> units -> {:forward, String.to_integer(units)}
          "down " <> units -> {:down, String.to_integer(units)}
          "up " <> units -> {:up, String.to_integer(units)}
        end)
      end)

      step "Add start position", fn input ->
        {{0, 0}, input}
      end

      step "Follow directions", Exercise.Renderer.GridMovement, fn {start, input} ->
        {intermediate, end_pos} =
          Enum.map_reduce(input, start, fn
            {:forward, units}, {pos, depth} -> {{pos + units, depth}, {pos + units, depth}}
            {:down, units}, {pos, depth} -> {{pos, depth + units}, {pos, depth + units}}
            {:up, units}, {pos, depth} -> {{pos, depth - units}, {pos, depth - units}}
          end)

        with_meta end_pos, intermediate: intermediate
      end

      step "Multiply positions", fn {pos, depth} ->
        pos * depth
      end
    end
  end
end
