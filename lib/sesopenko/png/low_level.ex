defmodule Sesopenko.PNG.LowLevel do
  alias Sesopenko.PNG.Config
  @dimension_bit_width 32
  @small_property_bit_width 8
  @color_type_grayscale 0
  @compression_method_inflate_deflate 0
  def header() do
    <<137, 80, 78, 71, 13, 10, 26, 10>>
  end

  def ihdr(%Config{} = config) do
    color_type =
      cond do
        config.color_type == :grayscale -> @color_type_grayscale
      end

    <<
      config.width::size(@dimension_bit_width),
      config.height::size(@dimension_bit_width),
      config.bit_depth::size(@small_property_bit_width),
      color_type::size(@small_property_bit_width),
      config.compression_method::size(@small_property_bit_width),
      config.filter_method::size(@small_property_bit_width),
      config.interlace_method::size(@small_property_bit_width)
    >>
  end
end
