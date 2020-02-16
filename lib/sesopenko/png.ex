defmodule Sesopenko.PNG do
  alias Sesopenko.PNG.LowLevel

  @moduledoc """
  Documentation for Sesopenko.PNG.
  """

  @doc """
  Produces a reference single red pixel image.

  See https://en.wikipedia.org/wiki/Portable_Network_Graphics#File_header
  """
  def reference_image() do
    red_string =
      "89504E470D0A1A0A0000000D4948445200000001000000010802000000907753DE0000000E4944415478DA62F8CFC0001060000301010066FD9F240000000049454E44AE426082"

    Hexate.decode(red_string)
  end

  def create(%Sesopenko.PNG.Config{} = config, scan_lines) do
    LowLevel.header() <>
      LowLevel.chunk(:ihdr, LowLevel.ihdr_content(config)) <>
      LowLevel.chunk(:idat, LowLevel.idat_content(config, scan_lines)) <>
      LowLevel.chunk(:iend)
  end
end
