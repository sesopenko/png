defmodule Sesopenko.PNG.LowLevelTest do
  alias Sesopenko.PNG
  use ExUnit.Case

  describe "header" do
    test "Should have a header" do
      header = PNG.LowLevel.header()

      assert header == <<137, 80, 78, 71, 13, 10, 26, 10>>
    end
  end

  describe "chunk" do
  end
end
