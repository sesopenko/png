defmodule Sesopenko.PNG.LowLevelTest do
  alias Sesopenko.PNG.LowLevel
  use ExUnit.Case
  @length_byte_length 4
  @type_byte_length 4
  @crc_byte_length 4

  test "Should have a header" do
    header = LowLevel.header()

    assert header == <<137, 80, 78, 71, 13, 10, 26, 10>>
  end

  describe "chunk" do
    # some of the byte values for these scenarios are thanks to
    # [Extracing PNG Chunks with Go](https://parsiya.net/blog/2018-02-25-extracting-png-chunks-with-go/)
    scenarios = [
      %{
        label: "ihdr chunk",
        input_chunk_type: :ihdr,
        input_data: Hexate.decode("0000006F000000730802000000"),
        expected_byte_length: 13,
        # Ascii string "IHDR":
        expected_cunk_type: <<73, 72, 68, 82>>,
        expected_crc: :binary.decode_unsigned(Hexate.decode("19B3CBD7")),
        crc_start: @length_byte_length + @type_byte_length + 13
      },
      %{
        label: "idat chunk",
        input_chunk_type: :idat,
        input_data: Hexate.decode("08D763F80F0001010100"),
        expected_byte_length: 10,
        # Ascii string "IDAT":
        expected_cunk_type: <<73, 68, 65, 84>>,
        expected_crc: :binary.decode_unsigned(Hexate.decode("1BB6EE56")),
        crc_start: @length_byte_length + @type_byte_length + 10
      },
      %{
        label: "iend chunk",
        input_chunk_type: :iend,
        input_data: <<>>,
        expected_byte_length: 0,
        # Ascii string "IEND":
        expected_cunk_type: <<73, 69, 78, 68>>,
        expected_crc: :binary.decode_unsigned(Hexate.decode("ae426082")),
        crc_start: @length_byte_length + @type_byte_length
      }
    ]

    for scenario <- scenarios do
      @tag expected_byte_length: scenario[:expected_byte_length]
      @tag input_chunk_type: scenario[:input_chunk_type]
      @tag input_data: scenario[:input_data]
      @tag expected_cunk_type: scenario[:expected_cunk_type]
      @tag crc_start: scenario[:crc_start]
      @tag expected_crc: scenario[:expected_crc]
      test scenario[:label], context do
        # Arranged in context via scenario data.
        # Act.
        result = LowLevel.chunk(context[:input_chunk_type], context[:input_data])
        # Assert.
        # should have length bytes at the beginning
        assert byte_size(result) >= @length_byte_length
        # get the length value
        length_portion = :binary.part(result, {0, @length_byte_length})
        length_result = :binary.decode_unsigned(length_portion)
        assert length_result == context[:expected_byte_length]

        # should get the expected chunk type
        assert byte_size(result) >= 8
        chunk_type_portion = :binary.part(result, {@length_byte_length, @type_byte_length})

        assert chunk_type_portion == context[:expected_cunk_type]

        # should have crc in bytes
        assert byte_size(result) >= context[:crc_start] + @crc_byte_length

        checksum =
          :binary.part(result, {context[:crc_start], @crc_byte_length})
          |> :binary.decode_unsigned()

        assert checksum == context[:expected_crc]
      end
    end
  end

  describe "ihdr_data" do
    test "ihdr_data" do
      # Arrange.
      input_width = 128
      input_height = 256
      expected_bit_depth = 8
      expected_compression_method = 0
      # color type grayscale == 0
      expected_filter_method = 0
      expected_interlace_method = 0

      input_config = Sesopenko.PNG.Config.get(input_width, input_height)

      # Act.
      ihdr_bytes = LowLevel.ihdr_content(input_config)

      # Assert.

      assert byte_size(ihdr_bytes) > 3
      # it contains (in this order)
      # width (4 bytes)
      assert_byte_value(ihdr_bytes, 0, 4, 128)
      # height (4 bytes)
      assert_byte_value(ihdr_bytes, 4, 4, 256)

      # bit depth (1 byte)
      assert byte_size(ihdr_bytes) >= 9
      assert_byte_value(ihdr_bytes, 8, 1, expected_bit_depth)
      # color type (1 byte)

      assert byte_size(ihdr_bytes) >= 10

      # compression method (1 byte)
      # should be zero since that's all PNG supports
      assert byte_size(ihdr_bytes) >= 11
      assert_byte_value(ihdr_bytes, 9, 1, expected_compression_method)

      # filter method (1 byte)
      assert byte_size(ihdr_bytes) >= 12
      assert_byte_value(ihdr_bytes, 10, 1, expected_filter_method)

      # interlace method (1 byte) (13 data bytes total)
      assert byte_size(ihdr_bytes) >= 13
      assert_byte_value(ihdr_bytes, 11, 1, expected_interlace_method)
    end
  end

  defp assert_byte_value(bytes, start_pos, length, expected_value) do
    portion_bytes = :binary.part(bytes, {start_pos, length})
    assert byte_size(portion_bytes) == length
    result = :binary.decode_unsigned(portion_bytes)
    assert result == expected_value
  end

  describe "scanlines_to_binary" do
    scenarios = [
      %{
        label: "single white pixel",
        input_scanlines: [
          [254]
        ],
        input_config: Sesopenko.PNG.Config.get(1, 1),
        expected_binary: <<254::size(8)>>
      },
      %{
        label: "single black pixel",
        input_scanlines: [
          [0]
        ],
        input_config: Sesopenko.PNG.Config.get(1, 1),
        expected_binary: <<0::size(8)>>
      },
      %{
        label: "two black pixels, horizontal",
        input_scanlines: [
          [0, 0]
        ],
        input_config: Sesopenko.PNG.Config.get(2, 1),
        expected_binary: <<0::size(8), 0::size(8)>>
      },
      %{
        label: "four white corners",
        input_scanlines: [
          [254, 0, 254],
          [0, 0, 0],
          [254, 0, 254]
        ],
        input_config: Sesopenko.PNG.Config.get(2, 1),
        expected_binary: <<
          254::size(8),
          0::size(8),
          254::size(8),
          0::size(8),
          0::size(8),
          0::size(8),
          254::size(8),
          0::size(8),
          254::size(8)
        >>
      }
    ]

    for scenario <- scenarios do
      @tag input_scanlines: scenario[:input_scanlines]
      @tag expected_binary: scenario[:expected_binary]
      @tag input_config: scenario[:input_config]
      test scenario[:label], context do
        # Arrange.
        input_scanlines = context[:input_scanlines]
        input_config = context[:input_config]
        expected_binary = context[:expected_binary]

        # Act.
        binary_result = LowLevel.scanlines_to_binary(input_config, input_scanlines)
        # Assert.
        assert binary_result == expected_binary
      end
    end
  end

  describe "idat_content" do
    test "single pixel white" do
      # See single_white.png for example PNG guiding this test
      # Arrange.
      input_scanlines = [[255]]
      input_config = Sesopenko.PNG.Config.get(1, 1)

      # Act.
      result = LowLevel.idat_content(input_config, input_scanlines)
      z_stream = :zlib.open()
      :zlib.inflateInit(z_stream)

      binary_deflated =
        :zlib.inflate(z_stream, result)
        |> :erlang.iolist_to_binary()

      :ok = :zlib.inflateEnd(z_stream)
      :ok = :zlib.close(z_stream)

      # Assert.
      assert byte_size(binary_deflated) == 1
      assert binary_deflated == <<255>>
    end
  end

  @doc """
  Should give a list of chunks for a given PNG image (binary)
  """
  describe "explode_chunks" do
    test "explode reference" do
      # Arrange.
      input_image = Sesopenko.PNG.reference_image()
      # Act.
      [ihdr, idata, iend] = LowLevel.explode_chunks(input_image)
      {ihdr_length, ihdr_type, ihdr_data, _ihdr_crc} = ihdr
      # Assert

      assert ihdr_length == 13
      assert ihdr_type == <<"IHDR">>

      <<
        width::unsigned-integer-32,
        height::unsigned-integer-32,
        bit_depth,
        color_type,
        compression_method,
        filter_method,
        interlace_method
      >> = ihdr_data

      assert width == 1
      assert height == 1
      assert bit_depth == 8
      assert color_type == 2
      assert compression_method == 0
      assert filter_method == 0
      assert interlace_method == 0

      {idat_length, idat_type, _idat_data, _idat_crc} = idata

      assert idat_length == 14
      assert idat_type == <<"IDAT">>
      {iend_length, iend_type, iend_dat, _iend_crc} = iend
      assert iend_length == 0
      assert iend_type == <<"IEND">>
      assert iend_dat == <<>>
    end
  end
end
