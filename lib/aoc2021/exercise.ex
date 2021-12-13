defmodule Aoc2021.Exercise do
  alias Aoc2021.FileHelpers

  @callback run(any) :: any
  @callback preprocess_input(binary) :: any
  @callback postprocess_output(any) :: binary
  @optional_callbacks preprocess_input: 1, postprocess_output: 1

  @input_base_dir Application.app_dir(:aoc2021, "priv/exercise_input")

  def run(module, input, postprocess_output \\ true),
    do:
      module.run(input)
      |> then(fn
        output when postprocess_output -> module.postprocess_output(output)
        output -> output
      end)

  def list_inputs(module), do: FileHelpers.get_all_files(input_path(module))

  def get_input(module, name, preprocess_input \\ true),
    do:
      FileHelpers.get_file(input_path(module, name))
      |> then(fn
        input when preprocess_input -> module.preprocess_input(input)
        input -> input
      end)

  def set_input(module, name, content) when name != "",
    do: FileHelpers.write_file(input_path(module, name), content)

  def delete_input(module, name), do: FileHelpers.delete_file(input_path(module, name))

  defmacro __using__(_) do
    quote do
      @behaviour Aoc2021.Exercise

      @impl true
      def preprocess_input(input) do
        input
        |> String.split("\n", trim: true)
      end

      @impl true
      def postprocess_output(output) when is_binary(output), do: output

      @impl true
      def postprocess_output(output), do: inspect(output, pretty: true, charlists: :as_lists)

      defoverridable preprocess_input: 1, postprocess_output: 1
    end
  end

  defp input_path(implementation, name \\ ""),
    do: Path.join([@input_base_dir, Atom.to_string(implementation), name])
end
