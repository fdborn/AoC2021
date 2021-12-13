defmodule Aoc2021.Exercise.Renderer do
  @callback render_input(any) :: any
  @callback render_step(any, any) :: any
end
