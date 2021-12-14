defmodule Aoc2021Web.ExerciseLive.ExerciseComponent do
  use Aoc2021Web, :live_component

  alias Aoc2021.Exercise
  alias Aoc2021.Exercise.Input

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:inputs, Input.list_inputs(assigns.exercise))

    {:ok, assign(socket, assigns)}
  end

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:input_mode, :show)
      |> assign(:selected, nil)
      |> assign(:results, [])

    {:ok, socket}
  end

  @impl true
  def handle_event("new", _params, socket) do
    socket =
      socket
      |> assign(:input_mode, :new)

    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", %{"name" => name}, socket) do
    socket =
      socket
      |> assign(:input_mode, :edit)
      |> assign(:edit_input_name, name)
      |> assign(:edit_input_content, Input.get_input(socket.assigns.exercise, name))

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"name" => name}, socket) do
    :ok = Input.delete_input(socket.assigns.exercise, name)

    socket =
      socket
      |> assign(:input_mode, :show)
      |> assign(:inputs, Input.list_inputs(socket.assigns.exercise))

    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"input" => input_params}, socket) do
    :ok = Input.set_input(socket.assigns.exercise, input_params["name"], input_params["content"])

    socket =
      socket
      |> assign(:inputs, Input.list_inputs(socket.assigns.exercise))
      |> assign(:input_mode, :show)

    {:noreply, socket}
  end

  @impl true
  def handle_event("run", _params, socket) do
    exercise = socket.assigns.exercise
    input = Input.get_input(exercise, socket.assigns.selected)

    results =
      exercise
      |> Exercise.run(input)
      |> Exercise.render()
      |> Exercise.wrap_components()

    {:noreply, assign(socket, :results, results)}
  end

  @impl true
  def handle_event("cancel", _params, socket) do
    {:noreply, assign(socket, :input_mode, :show)}
  end

  @impl true
  def handle_event("select", %{"name" => name}, socket) do
    {:noreply, assign(socket, :selected, name)}
  end

  defp input_form(assigns) do
    ~H"""
    <.form let={f} for={:input} phx-submit="save" phx-target={@myself} class={@class} >
      <%= text_input f, :name, value: @name, readonly: @name != "" %>
      <%= textarea f, :content, value: @content %>
      <%= submit "Save", phx_disable_with: "saving..." %>

      <button
        type="button"
        phx-click="cancel"
        phx-target={@myself}
      >
        cancel
      </button>
    </.form>
    """
  end

  defp result(assigns) do
    results =
      case assigns.result do
        {:component, fun, assigns} -> component(fun, assigns)
        {:live_component, assigns} -> live_component(assigns)
      end

    assigns
    |> assign(:results, results)

    ~H"<%= results %>"
  end
end
