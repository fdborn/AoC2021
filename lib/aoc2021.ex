defmodule Aoc2021 do
  @moduledoc """
  Aoc2021 keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @exercises %{
    "1" => [Aoc2021.Exercises.Day01.Part1, Aoc2021.Exercises.Day01.Part2],
    "2" => [Aoc2021.Exercises.Day02.Part1, Aoc2021.Exercises.Day02.Part2],
    "3" => [Aoc2021.Exercises.Day03.Part1, Aoc2021.Exercises.Day03.Part2],
    "4" => [Aoc2021.Exercises.Day04.Part1, Aoc2021.Exercises.Day04.Part2],
    "5" => [Aoc2021.Exercises.Day05.Part1, Aoc2021.Exercises.Day05.Part2],
    "6" => [Aoc2021.Exercises.Day06.Part1, Aoc2021.Exercises.Day06.Part2],
  }

  def list_days() do
    for n <- 1..24, do: Integer.to_string(n)
  end

  def list_exercises(), do: @exercises

  def get_exercises(day), do: Map.fetch(@exercises, day)

end
