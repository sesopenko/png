defmodule Sesopenko.PNG.LowLevel do
  alias Sesopenko.PNG.Config
  @dimension_bit_width 32
  @small_property_bit_width 8
  @crc_bit_width 32
  @color_type_grayscale 0
  @chunk_length_bit_width 32
  @compression_method_inflate_deflate 0

  @header <<137, 80, 78, 71, 13, 10, 26, 10>>

  @deflate_compression_level 9

  def header() do
    @header
  end

  def chunk(:iend) do
    chunk(:iend, <<>>)
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

    length_prefix = <<byte_size(data)::size(@chunk_length_bit_width)>>
    crc_integer = :erlang.crc32(type_bytes <> data)
    crc_bitstring = <<crc_integer::size(@crc_bit_width)>>
    length_prefix <> type_bytes <> data <> crc_bitstring
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
    # learn about flushing here: http://www.bolet.org/~pornin/deflate-flush.html
    z_stream = :zlib.open()
    :zlib.deflateInit(z_stream, @deflate_compression_level)
    # the stream isn't flushed with the same arity as the input data
    binary =
      :zlib.deflate(z_stream, scanlines, :finish)
      |> :erlang.iolist_to_binary()

    :ok = :zlib.deflateEnd(z_stream)
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

  def explode_chunks(<<@header, rest::binary>>) do
    IO.puts("stripped header")
    explode_chunks(rest, [])
  end

  def explode_chunks(
        <<
          chunk_size::unsigned-integer-32,
          chunk_type::binary-size(4),
          chunk::binary-size(chunk_size),
          crc::unsigned-integer-32,
          rest::binary
        >>,
        accum
      ) do
    explode_chunks(rest, accum ++ [{chunk_size, chunk_type, chunk, crc}])
  end

  def explode_chunks(
        <<>>,
        accum
      ) do
    accum
  end
end
