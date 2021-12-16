defmodule Aoc2021.Exercise.Renderer.Default do
  @behaviour Aoc2021.Exercise.Renderer

  @impl true
  def render(result, _meta) do
    {Aoc2021Web.RendererComponents.Default, %{result: result}}
  end
end
