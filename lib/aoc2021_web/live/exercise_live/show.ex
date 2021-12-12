defmodule Aoc2021Web.ExerciseLive.Show do
  use Aoc2021Web, :live_view

  alias Aoc2021Web.ExerciseLive.ExerciseComponent

  @impl true
  def handle_params(params, _uri, socket) do
    socket =
      case Aoc2021.get_exercises(params["day"]) do
        {:ok, exercises} ->
          socket
          |> assign(:exercises, exercises)
          |> assign(:day, params["day"])

        :error ->
          push_redirect(socket, to: "/")
      end

    {:noreply, socket}
  end
end
