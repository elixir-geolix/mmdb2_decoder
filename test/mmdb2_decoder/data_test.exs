defmodule MMDB2Decoder.DataTest do
  use ExUnit.Case, async: true
  use Bitwise

  alias MMDB2Decoder.TestHelpers.Fixture

  test "decoded values" do
    {meta, tree, data} =
      :fixture_decoder
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    decoded = MMDB2Decoder.lookup({1, 1, 1, 0}, meta, tree, data)

    assert decoded[:utf8_string] == "unicode! ☯ - ♫"
    assert decoded[:double] == 42.123456
    assert decoded[:bytes] == <<0, 0, 0, 42>>
    assert decoded[:uint16] == 100
    assert decoded[:uint32] == :math.pow(2, 28)
    assert decoded[:int32] == -1 * :math.pow(2, 28)
    assert decoded[:uint64] == 1 <<< 60
    assert decoded[:uint128] == 1 <<< 120
    assert decoded[:array] == [1, 2, 3]
    assert decoded[:map] == %{mapX: %{arrayX: [7, 8, 9], utf8_stringX: "hello"}}
    assert decoded[:boolean] == true
    assert decoded[:float] == 1.1
  end
end
