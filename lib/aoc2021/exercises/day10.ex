defmodule Aoc2021.Exercises.Day10 do
  alias Aoc2021.Exercise
  alias Aoc2021.Exercises.Day10.ChunkParser

  defmodule Part1 do
    use Exercise

    exercise "Part 1" do
      step("Preprocess input", fn input ->
        input
        |> String.split("\n", trim: true)
        |> Enum.map(&String.graphemes/1)
      end)

      step("Try to parse each line", fn input ->
        input
        |> Enum.map(&ChunkParser.parse/1)
      end)

      step("Filter incomplete patterns", fn input ->
        input
        |> Enum.reject(&match?({:eof, _}, &1))
      end)

      defp char_score(")"), do: 3
      defp char_score("]"), do: 57
      defp char_score("}"), do: 1197
      defp char_score(">"), do: 25137

      step("Calculate error score", fn input ->
        input
        |> Enum.map(&elem(&1, 1))
        |> Enum.map(&char_score/1)
        |> Enum.sum()
      end)
    end
  end

  defmodule Part2 do
    use Exercise

    exercise "Part 2" do
      step("Preprocess input", fn input ->
        input
        |> String.split("\n", trim: true)
        |> Enum.map(&String.graphemes/1)
      end)

      step("Try to parse each line", fn input ->
        input
        |> Enum.map(&ChunkParser.parse/1)
      end)

      step("Filter broken patterns", fn input ->
        input
        |> Enum.reject(&match?({:unexpected, _}, &1))
      end)

      defp completion_score("("), do: 1
      defp completion_score("["), do: 2
      defp completion_score("{"), do: 3
      defp completion_score("<"), do: 4

      step("Calculate completion scores", fn input ->
        input
        |> Enum.map(fn {_, cache} ->
          cache
          |> Enum.map(&completion_score/1)
          |> Enum.reduce(0, fn score, total -> total * 5 + score end)
        end)
      end)

      step("Take the middle value", fn input ->
        input
        |> Enum.sort()
        |> Enum.at(trunc(length(input) / 2))
      end)
    end
  end

  defmodule ChunkParser do
    def parse(line) do
      do_parse(line, [])
    end

    defp do_parse([], []), do: :ok
    defp do_parse([], cache), do: {:eof, cache}

    defp do_parse([head | tail], cache) do
      case test(head, cache) do
        {:continue, cache} -> do_parse(tail, cache)
        {:error, token} -> {:unexpected, token}
      end
    end

    @opening ["(", "[", "{", "<"]
    @closing [")", "]", "}", ">"]

    # Opening brackets
    defp test(bracket, cache) when bracket in @opening, do: {:continue, [bracket | cache]}

    # Matches
    defp test(")", ["(" | rest]), do: {:continue, rest}
    defp test("]", ["[" | rest]), do: {:continue, rest}
    defp test("}", ["{" | rest]), do: {:continue, rest}
    defp test(">", ["<" | rest]), do: {:continue, rest}

    # Unexpected closing brackets
    defp test(bracket, _cache) when bracket in @closing, do: {:error, bracket}
  end
end
