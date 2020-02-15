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
        expected_crc: Hexate.decode("19b3cbd7"),
        crc_start: @length_byte_length + @type_byte_length + 13
      },
      %{
        label: "idat chunk",
        input_chunk_type: :idat,
        input_data: Hexate.decode("0000006F000000730802000000"),
        expected_byte_length: 13,
        # Ascii string "IDAT":
        expected_cunk_type: <<73, 68, 65, 84>>,
        expected_crc: Hexate.decode("19b3cbd7"),
        crc_start: @length_byte_length + @type_byte_length + 13
      },
      %{
        label: "iend chunk",
        input_chunk_type: :iend,
        input_data: <<>>,
        expected_byte_length: 0,
        # Ascii string "IEND":
        expected_cunk_type: <<73, 69, 78, 68>>,
        expected_crc: Hexate.decode("ae426082"),
        crc_start: @length_byte_length + @type_byte_length
      }
    ]

    for scenario <- scenarios do
      @tag expected_byte_length: scenario[:expected_byte_length]
      @tag input_chunk_type: scenario[:input_chunk_type]
      @tag input_data: scenario[:input_data]
      @tag expected_cunk_type: scenario[:expected_cunk_type]
      @tag crc_start: scenario[:crc_start]
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
        checksum_portion = :binary.part(result, {context[:crc_start], @crc_byte_length})
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
      expected_color_type = 0
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

  @doc """
  Assert the given value for bytes in the given position of a given byte string.
  """
  defp assert_byte_value(bytes, start_pos, length, expected_value) do
    portion_bytes = :binary.part(bytes, {start_pos, length})
    assert byte_size(portion_bytes) == length
    result = :binary.decode_unsigned(portion_bytes)
    assert result == expected_value
  end
end
