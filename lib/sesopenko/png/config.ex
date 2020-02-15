defmodule Sesopenko.PNG.Config do
  @moduledoc """
  Data structure for PNG configuration.

  Compiles data for IHDR chunk.
  """

  @compression_method_none 0
  @filter_method_none 0
  @interlaced_method_disabled 0
  defstruct [
    :width,
    :height,
    :bit_depth,
    :color_type,
    :compression_method,
    :filter_method,
    :interlaced_method
  ]

  def get(width, height) do
    %Sesopenko.PNG.Config{
      width: width,
      height: height,
      bit_depth: 8,
      color_type: :grayscale,
      compression_method: @compression_method_none,
      filter_method: @filter_method_none,
      interlaced_method: @interlaced_method_disabled
    }
  end
end
