defmodule Aoc2021.Exercise.FileHelpers do
  def get_all_files(path) do
    case File.ls(path) do
      {:ok, files} -> files
      {:error, _} -> []
    end
  end

  def get_file(path) do
    case File.read(path) do
      {:ok, binary} -> binary
      {:error, _} -> ""
    end
  end

  def delete_file(path), do: File.rm(path)

  def write_file(path, content) do
    dirname = Path.dirname(path)

    unless File.exists?(dirname) do
      File.mkdir_p!(dirname)
    end

    File.write(path, content)
  end
 end
