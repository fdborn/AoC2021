defmodule Aoc2021.Exercise.Input do
  alias Aoc2021.Exercise.FileHelpers

  @input_base_dir Application.app_dir(:aoc2021, "priv/exercise_input")

  def list_inputs(module), do: FileHelpers.get_all_files(input_path(module))
  def get_input(module, name), do: FileHelpers.get_file(input_path(module, name))
  def delete_input(module, name), do: FileHelpers.delete_file(input_path(module, name))

  def set_input(module, name, content) when name != "",
    do: FileHelpers.write_file(input_path(module, name), content)

  defp input_path(implementation, name \\ ""),
    do: Path.join([@input_base_dir, Atom.to_string(implementation), name])
end
