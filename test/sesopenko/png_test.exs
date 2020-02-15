defmodule Sesopenko.PNGTest do
  alias Sesopenko.PNG
  use ExUnit.Case
  doctest Sesopenko.PNG

  test "reference_image" do
    red_string =
      "89504E470D0A1A0A0000000D4948445200000001000000010802000000907753DE0000000E4944415478DA62F8CFC0001060000301010066FD9F240000000049454E44AE426082"

    red_binary = Sesopenko.PNG.reference_image()

    header = :binary.part(red_binary, {0, 8})

    assert header == <<137, 80, 78, 71, 13, 10, 26, 10>>
  end
end
