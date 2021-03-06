defmodule Aoc2021.Exercise.Macros do
  @default_renderer Aoc2021.Exercise.Renderer.Default

  defmacro exercise(name, do: block) do
    quote do
      exercise(unquote(name), unquote(@default_renderer), do: unquote(block))
    end
  end

  defmacro exercise(name, renderer, do: block) do
    block =
      quote do
        @exercise_start_index 1
        @exercise_steps []
        @exercise_renderer unquote(renderer)
        unquote(block)
      end

    name =
      quote do
        @impl true
        def name(), do: unquote(name)
      end

    steps =
      quote do
        def steps(), do: @exercise_steps
      end

    run =
      quote do
        @impl true
        def run(input) do
          {intermediate_results, _last_result} =
            @exercise_steps
            |> Enum.reverse()
            |> Enum.with_index(@exercise_start_index)
            |> Enum.map_reduce(input, fn {{description, module, meta}, index}, input ->
              {result, meta} =
                case :timer.tc(module, :run_step, [description, input]) do
                  {elapsed, %{__exercise__meta__: true, result: result, meta: new_meta}} ->
                    meta =
                      meta
                      |> Keyword.merge(new_meta)
                      |> Keyword.put(:elapsed, elapsed)

                    {result, meta}

                  {elapsed, result} ->
                    meta = Keyword.put(meta, :elapsed, elapsed)

                    {result, meta}
                end

              meta =
                meta
                |> Keyword.put(:description, description)
                |> Keyword.put(:step, index)

              {{result, meta}, result}
            end)

          intermediate_results
        end

        @exercise_steps nil
      end

    recompile =
      quote do

      def recompile() do
        source = __MODULE__.module_info(:compile)[:source]

        {:ok, _modules, _warning} = Kernel.ParallelCompiler.compile([source])
      end
    end

    quote do
      unquote(block)
      unquote(name)
      unquote(steps)
      unquote(run)
      unquote(recompile)
    end
  end

  defmacro step(description, renderer, callback) do
    quote do
      if steps = @exercise_steps do
        meta = [renderer: unquote(renderer)]

        @exercise_steps [
          {unquote(description), unquote(__CALLER__.module), meta} | steps
        ]

        def run_step(unquote(description), input) do
          unquote(callback).(input)
        end
      else
        raise "Cannot place step outside of exercise"
      end
    end
  end

  defmacro step(description, callback) do
    quote do
      step(unquote(description), @exercise_renderer, unquote(callback))
    end
  end

  defmacro with_meta(result, meta) do
    quote do
      %{
        __exercise__meta__: true,
        result: unquote(result),
        meta: unquote(meta)
      }
    end
  end
end
