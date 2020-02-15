defmodule Sesopenko.PNG do
  @moduledoc """
  Documentation for Sesopenko.PNG.
  """
  defmodule LowLevel do
    def header() do
      <<137, 80, 78, 71, 13, 10, 26, 10>>
    end
  end

  @doc """
  Produces a reference single red pixel image.

  See https://en.wikipedia.org/wiki/Portable_Network_Graphics#File_header
  """
  def reference_image() do
    red_string =
      "89504E470D0A1A0A0000000D4948445200000001000000010802000000907753DE0000000E4944415478DA62F8CFC0001060000301010066FD9F240000000049454E44AE426082"

    Hexate.decode(red_string)
  end

  def create(_scan_lines) do
    LowLevel.header()
  end
end
