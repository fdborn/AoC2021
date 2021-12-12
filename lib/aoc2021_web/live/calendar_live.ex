defmodule Aoc2021Web.CalendarLive do
  use Aoc2021Web, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Calendar")
      |> assign(:days, Aoc2021.list_days())
      |> assign(:exercises, Aoc2021.list_exercises())

    {:ok, socket}
  end
end
