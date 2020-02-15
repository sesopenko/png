defmodule Sesopenko.PNG.ConfigTest do
  alias Sesopenko.PNG.Config
  use ExUnit.Case

  test "should get a bare bones config" do
    # Arrange.
    input_width = 128
    input_height = 128

    expected_config = %Config{
      width: 128,
      height: 128,
      bit_depth: 8,
      color_type: :grayscale,
      compression_method: 0,
      filter_method: 0,
      interlaced_method: 0
    }

    # Act.
    resulting_config = Config.get(input_height, input_width)

    # Assert
    assert resulting_config == expected_config
  end
end
