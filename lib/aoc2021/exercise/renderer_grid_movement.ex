defmodule Aoc2021.Exercise.Renderer.GridMovement do
  @behaviour Aoc2021.Exercise.Renderer

  @impl true
  def render(result, meta) do
    assigns = %{
      id: meta[:description] <> Integer.to_string(System.unique_integer([:positive])),
      module: Aoc2021Web.RendererComponents.GridMovement,
      result: result,
      meta: meta
    }

    {:live_component, assigns}
  end
end
