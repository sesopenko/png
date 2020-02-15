defmodule Sesopenko.PNG.LowLevelTest do
  alias Sesopenko.PNG.LowLevel
  use ExUnit.Case

  test "Should have a header" do
    header = LowLevel.header()

    assert header == <<137, 80, 78, 71, 13, 10, 26, 10>>
  end

  describe "chunks" do
    test "ihdr" do
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
      ihdr_bytes = LowLevel.ihdr(input_config)

      # Assert.

      # must be the first chunk
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
