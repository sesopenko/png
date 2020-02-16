defmodule Sesopenko.PNGTest do
  alias Sesopenko.PNG
  use ExUnit.Case
  doctest Sesopenko.PNG

  describe "create" do
    test "single white pixel greyscale 8 bit image" do
      # Arrange.
      input_config = Sesopenko.PNG.Config.get(1, 1)
      input_scanlines = [[255]]
      # Act.
      result = PNG.create(input_config, input_scanlines)
      [ihdr, idat, iend] = Sesopenko.PNG.LowLevel.explode_chunks(result)

      # Assert.
      # Should have an 8 byte header
      {
        _,
        <<"IHDR">>,
        <<
          width::unsigned-integer-32,
          height::unsigned-integer-32,
          bit_depth,
          color_type,
          compression_method,
          filter_method,
          interlace_method
        >>,
        _crc
      } = ihdr

      assert width == 1
      assert height == 1
      assert bit_depth == 8
      assert color_type == 0
      assert compression_method == 0
      assert filter_method == 0
      assert interlace_method == 0

      {
        _idat_length,
        <<"IDAT">>,
        idat_data,
        _idat_crc
      } = idat

      z_stream = :zlib.open()
      :zlib.inflateInit(z_stream)

      img_data =
        :zlib.inflate(z_stream, idat_data)
        |> :erlang.iolist_to_binary()

      :ok = :zlib.inflateEnd(z_stream)
      :ok = :zlib.close(z_stream)

      assert img_data == <<0, 255>>

      {
        _iend_length,
        <<"IEND">>,
        <<>>,
        _iend_crc
      } = iend
    end
  end
end
