defmodule Sesopenko.PNG.LowLevel do
  alias Sesopenko.PNG.Config
  @dimension_bit_width 32
  @small_property_bit_width 8
  @crc_bit_width 32
  @color_type_grayscale 0
  @chunk_length_bit_width 32
  @compression_method_inflate_deflate 0

  def header() do
    <<137, 80, 78, 71, 13, 10, 26, 10>>
  end

  @doc """
  Creates binary chunk for given type & data
  """
  def chunk(type, data) do
    type_bytes =
      cond do
        type == :ihdr -> <<"IHDR">>
        type == :idat -> <<"IDAT">>
        type == :iend -> <<"IEND">>
      end

    prefix = <<byte_size(data)::size(@chunk_length_bit_width)>> <> type_bytes
    package = prefix <> data
    crc_integer = :erlang.crc32(package)
    package <> <<crc_integer::size(@crc_bit_width)>>
  end

  @doc """
  Produces a binary IHDR header from a given config.
  """
  def ihdr_content(%Config{} = config) do
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

  def idat_content(%Config{} = config, scanlines) when is_list(scanlines) do
    bytes = scanlines_to_binary(config, scanlines)
    z_stream = :zlib.open()
    :zlib.deflateInit(z_stream)
    # the stream isn't flushed with the same arity as the input data
    binary =
      :zlib.deflate(z_stream, scanlines, :finish)
      |> :erlang.iolist_to_binary()

    :ok = :zlib.close(z_stream)
    binary
  end

  @doc """

  Example input scanlines:
  ```elixir
  image_with_white_corners = [
    [254, 0, 254],
    [0, 0, 0],
    [254, 0, 254]
  ]
  ```
  """
  def scanlines_to_binary(%Config{} = config, scanlines) when is_list(scanlines) do
    # flatten the scanlines into a single binary string
    # scanlines are in the following form
    binary_string =
      scanlines
      |> Stream.concat()
      |> Stream.map(fn integer_value ->
        byte_size =
          cond do
            config.bit_depth == 8 -> 8
          end

        <<integer_value::size(byte_size)>>
      end)
      |> Enum.reduce(<<>>, fn value, accumulator -> accumulator <> value end)
  end
end
