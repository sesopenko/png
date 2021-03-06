defmodule Sesopenko.PNG.Config do
  @moduledoc """
  Data structure for PNG configuration.

  Compiles data for IHDR chunk.
  """

  # inflate deflate with a sliding window of at mose 32768 bytes
  # [PNG Chunks](http://www.libpng.org/pub/png/spec/1.2/PNG-Chunks.html)
  @compression_method_inflate_deflate 0
  @filter_method_none 0
  @interlace_method_disabled 0
  defstruct [
    :width,
    :height,
    :bit_depth,
    :color_type,
    :compression_method,
    :filter_method,
    :interlace_method
  ]

  def get(width, height) do
    %Sesopenko.PNG.Config{
      width: width,
      height: height,
      bit_depth: 8,
      color_type: :grayscale,
      compression_method: @compression_method_inflate_deflate,
      filter_method: @filter_method_none,
      interlace_method: @interlace_method_disabled
    }
  end
end
