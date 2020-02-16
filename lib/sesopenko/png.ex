defmodule Sesopenko.PNG do
  @moduledoc """
  Generates PNG bitstrings.
  """

  @doc """
  Produces a reference single red pixel image.

  See https://en.wikipedia.org/wiki/Portable_Network_Graphics#File_header
  """
  alias Sesopenko.PNG.LowLevel

  def reference_image() do
    red_string =
      "89504E470D0A1A0A0000000D4948445200000001000000010802000000907753DE0000000E4944415478DA62F8CFC0001060000301010066FD9F240000000049454E44AE426082"

    Hexate.decode(red_string)
  end

  @doc """
  Creates a PNG for a given config and scan_lines.

  `Sesopenko.PNG.Config.get/2` simplifies config building.

  Example scanlines for a black box with white corners:
  ```elixir
  image_with_white_corners = [
  [254, 0, 254],
  [0, 0, 0],
  [254, 0, 254]
  ]
  ```

  """
  def create(%Sesopenko.PNG.Config{} = config, scan_lines) do
    LowLevel.header() <>
      LowLevel.chunk(:ihdr, LowLevel.ihdr_content(config)) <>
      LowLevel.chunk(:idat, LowLevel.idat_content(config, scan_lines)) <>
      LowLevel.chunk(:iend)
  end
end
