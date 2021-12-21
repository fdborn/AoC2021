defmodule Aoc2021.Exercise do
  @callback name() :: binary
  @callback run(any) :: any

  defmacro __using__(_) do
    quote do
      @behaviour Aoc2021.Exercise
      import Aoc2021.Exercise.Macros
    end
  end

  def name(module), do: module.name()

  def run(module, input) do
    {:ok, exercise_pid} =
      Task.start(fn ->
        results = module.run(input)

        Phoenix.PubSub.broadcast(Aoc2021.PubSub, "results:#{module.name()}", {:results, results})
      end)

    Task.start(fn ->
      Process.monitor(exercise_pid)

      receive do
        {_, _, _, _, :normal} ->
          nil

        {_, _, _, _, :noproc} ->
          nil

        {_, _, _, _, exit} ->
          Phoenix.PubSub.broadcast(
            Aoc2021.PubSub,
            "results:#{module.name()}",
            {:run_error, exit}
          )
      end
    end)

    nil
  end

  def render(results) do
    Enum.map(results, fn {result, meta} ->
      {component, view_data} = meta[:renderer].render(result, meta)

      meta =
        meta
        |> Keyword.merge(Map.to_list(view_data))

      {component, meta}
    end)
  end

  def subscribe(name), do: Phoenix.PubSub.subscribe(Aoc2021.PubSub, "results:#{name}")
end
