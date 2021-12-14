defmodule Aoc2021Web.RendererComponents.GridMovement do
  use Aoc2021Web, :live_component

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:show_result, false)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    moves =
      assigns.meta[:intermediate]
      |> Enum.map(&Tuple.to_list/1)
      |> Jason.encode!()

    assigns =
      assigns
      |> assign(:moves, moves)

    ~H"""
    <div class="grid-movement">
      <div
        class="grid-movement-grid"
        phx-hook="GridMovement"
        data-moves-data={@moves}
        id={System.unique_integer([:positive])}
      >
        <canvas width="600" height="600" />
      </div>
    </div>
    """
  end
end
