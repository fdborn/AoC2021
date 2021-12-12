defmodule Aoc2021 do
  @moduledoc """
  Aoc2021 keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """


  @exercises %{
    "1" => [Aoc2021.Exercises.Day01.PartOne, Aoc2021.Exercises.Day01.PartTwo]
  }

  def list_days() do
    for n <- 1..24, do: Integer.to_string(n)
  end

  def list_exercises(), do: @exercises

  def get_exercises(day), do: Map.fetch(@exercises, day)

end
