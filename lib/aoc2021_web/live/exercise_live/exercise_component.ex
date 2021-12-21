defmodule Aoc2021Web.ExerciseLive.ExerciseComponent do
  use Aoc2021Web, :live_view

  alias Aoc2021.Exercise
  alias Aoc2021.Exercise.Input

  @impl true
  def mount(_params, session, socket) do
    exercise = session["exercise"]

    socket =
      socket
      |> assign(:name, Exercise.name(exercise))
      |> assign(:exercise, exercise)
      |> assign(:inputs, Input.list_inputs(exercise))
      |> assign(:input_mode, :show)
      |> assign(:selected, nil)
      |> assign(:results, [])
      |> assign(:waiting, false)
      |> assign(:error, nil)

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

    Exercise.subscribe(socket.assigns.name)
    Exercise.run(exercise, input)

    Process.send_after(self(), :long_wait, 5_000)

    socket =
      socket
      |> assign(:waiting, true)
      |> assign(:error, nil)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:results, results}, socket) do
    results =
      results
      |> Exercise.render()

    socket =
      socket
      |> assign(:results, results)
      |> assign(:waiting, false)
      |> assign(:error, nil)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:run_error, exit}, socket) do
    socket =
      socket
      |> assign(:waiting, false)
      |> assign(:error, Exception.format_exit(exit))

    {:noreply, socket}
  end

  @impl true
  def handle_info(:long_wait, socket) do
    socket = if socket.assigns.waiting, do: assign(socket, :waiting, :long), else: socket

    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _params, socket) do
    {:noreply, assign(socket, :input_mode, :show)}
  end

  @impl true
  def handle_event("select", %{"name" => name}, socket) do
    socket =
      socket
      |> assign(:selected, name)
      |> assign(:results, [])

    {:noreply, socket}
  end

  @impl true
  def handle_event("recompile", _unsigned_params, socket) do
    socket.assigns.exercise.recompile()

    {:noreply, socket}
  end

  defp input_form(assigns) do
    ~H"""
    <.form let={f} for={:input} phx-submit="save" class={@class} >
      <%= text_input f, :name, value: @name, readonly: @name != "" %>
      <%= textarea f, :content, value: @content %>
      <%= submit "Save", phx_disable_with: "saving...", disabled: @disabled %>

      <button
        type="button"
        phx-click="cancel"
        disabled={@disabled}
      >
        cancel
      </button>
    </.form>
    """
  end

  defp result(assigns) do
    component_assigns = %{
      id: "#{assigns.meta[:description]}-#{System.unique_integer([:positive])}",
      module: assigns.component,
      meta: assigns.meta
    }

    rendered = live_component(component_assigns)

    elapsed =
      Timex.Duration.from_microseconds(assigns.meta[:elapsed])
      |> Timex.Format.Duration.Formatters.Humanized.format()

    assigns =
      assigns
      |> assign(:rendered, rendered)
      |> assign(:elapsed, elapsed)

    ~H"""
    <div class="exercise-result-meta">Took: <%= @elapsed %></div>
    <div class="exercise-result-headline">Result:</div>
    <div class="exercise-result-content">
      <%= @rendered %>
    </div>
    """
  end
end
