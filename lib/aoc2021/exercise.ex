defmodule Aoc2021.Exercise do
  alias Aoc2021.FileHelpers

  @callback run(any) :: any
  @callback preprocess_input(binary) :: any
  @optional_callbacks preprocess_input: 1

  @input_base_dir Application.app_dir(:aoc2021, "priv/exercise_input")

  def run(module, input), do: module.run(input)
  def list_inputs(module), do: FileHelpers.get_all_files(input_path(module))

  def get_input(module, name),
    do:
      FileHelpers.get_file(input_path(module, name))
      |> module.preprocess_input

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

      defoverridable preprocess_input: 1
    end
  end

  defp input_path(implementation, name \\ ""),
    do: Path.join([@input_base_dir, Atom.to_string(implementation), name])
end
