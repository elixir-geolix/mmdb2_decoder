defmodule MMDB2Decoder.DataTest do
  use ExUnit.Case, async: true
  use Bitwise

  alias MMDB2Decoder.TestHelpers.Fixture

  test "ipv4 24 bit record size" do
    {:ok, meta, tree, data} =
      :fixture_ipv4_24
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert meta.record_size == 24

    {:ok, result} = MMDB2Decoder.lookup({1, 1, 1, 3}, meta, tree, data)

    assert result == %{"ip" => "1.1.1.2"}
  end

  test "ipv4 28 bit record size" do
    {:ok, meta, tree, data} =
      :fixture_ipv4_28
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert meta.record_size == 28

    {:ok, result} = MMDB2Decoder.lookup({1, 1, 1, 3}, meta, tree, data)

    assert result == %{"ip" => "1.1.1.2"}
  end

  test "ipv4 32 bit record size" do
    {:ok, meta, tree, data} =
      :fixture_ipv4_32
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert meta.record_size == 32

    {:ok, result} = MMDB2Decoder.lookup({1, 1, 1, 3}, meta, tree, data)

    assert result == %{"ip" => "1.1.1.2"}
  end

  test "ipv6 24 bit record size" do
    {:ok, meta, tree, data} =
      :fixture_ipv6_24
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert meta.record_size == 24

    {:ok, result} = MMDB2Decoder.lookup({0, 0, 0, 0, 0, 2, 0, 65}, meta, tree, data)

    assert result == %{"ip" => "::2:0:40"}
  end

  test "ipv6 28 bit record size" do
    {:ok, meta, tree, data} =
      :fixture_ipv6_28
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert meta.record_size == 28

    {:ok, result} = MMDB2Decoder.lookup({0, 0, 0, 0, 0, 2, 0, 65}, meta, tree, data)

    assert result == %{"ip" => "::2:0:40"}
  end

  test "ipv6 32 bit record size" do
    {:ok, meta, tree, data} =
      :fixture_ipv6_32
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert meta.record_size == 32

    {:ok, result} = MMDB2Decoder.lookup({0, 0, 0, 0, 0, 2, 0, 65}, meta, tree, data)

    assert result == %{"ip" => "::2:0:40"}
  end

  test "ipv6-in-ipv4 24 bit record size" do
    {:ok, meta, tree, data} =
      :fixture_ipv4_24
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert meta.record_size == 24

    {:ok, result} = MMDB2Decoder.lookup({0, 0, 0, 0, 0, 65_535, 257, 257}, meta, tree, data)

    assert result == %{"ip" => "1.1.1.1"}
  end

  test "ipv6-in-ipv4 28 bit record size" do
    {:ok, meta, tree, data} =
      :fixture_ipv4_28
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert meta.record_size == 28

    {:ok, result} = MMDB2Decoder.lookup({0, 0, 0, 0, 0, 65_535, 257, 257}, meta, tree, data)

    assert result == %{"ip" => "1.1.1.1"}
  end

  test "ipv6-in-ipv4 32 bit record size" do
    {:ok, meta, tree, data} =
      :fixture_ipv4_32
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert meta.record_size == 32

    {:ok, result} = MMDB2Decoder.lookup({0, 0, 0, 0, 0, 65_535, 257, 257}, meta, tree, data)

    assert result == %{"ip" => "1.1.1.1"}
  end

  test "decoded values" do
    {:ok, decoded} =
      :fixture_decoder
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()
      |> MMDB2Decoder.pipe_lookup({1, 1, 1, 0})

    assert decoded["array"] == [1, 2, 3]
    assert decoded["boolean"] == true
    assert decoded["bytes"] == <<0, 0, 0, 42>>
    assert decoded["double"] == 42.123456
    assert decoded["float"] == 1.100000023841858
    assert decoded["int32"] == -1 * :math.pow(2, 28)
    assert decoded["map"] == %{"mapX" => %{"arrayX" => [7, 8, 9], "utf8_stringX" => "hello"}}
    assert decoded["uint16"] == 100
    assert decoded["uint32"] == :math.pow(2, 28)
    assert decoded["uint64"] == 1 <<< 60
    assert decoded["uint128"] == 1 <<< 120
    assert decoded["utf8_string"] == "unicode! ☯ - ♫"
  end

  test "decoded MAX values" do
    {:ok, decoded} =
      :fixture_decoder
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()
      |> MMDB2Decoder.pipe_lookup({255, 255, 255, 255})

    # credo:disable-for-next-line Credo.Check.Readability.LargeNumbers
    assert decoded["double"] == 9.218868437227405e18
    assert decoded["float"] == 2_139_095_040.0
    assert decoded["int32"] == 2_147_483_647
    assert decoded["uint16"] == 65_535
    assert decoded["uint32"] == 4_294_967_295
    assert decoded["uint64"] == 18_446_744_073_709_551_615
    assert decoded["uint128"] == 340_282_366_920_938_463_463_374_607_431_768_211_455
  end

  test "decoded MIN values" do
    {:ok, decoded} =
      :fixture_decoder
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()
      |> MMDB2Decoder.pipe_lookup({0, 0, 0, 0})

    assert decoded["array"] == []
    assert decoded["boolean"] == false
    assert decoded["bytes"] == ""
    assert decoded["double"] == 0.0
    assert decoded["float"] == 0.0
    assert decoded["int32"] == 0
    assert decoded["map"] == %{}
    assert decoded["uint16"] == 0
    assert decoded["uint32"] == 0
    assert decoded["uint64"] == 0
    assert decoded["uint128"] == 0
    assert decoded["utf8_string"] == ""
  end

  test "decoded values with non-default options" do
    options = %{
      double_precision: 0,
      float_precision: 0,
      map_keys: :atoms!
    }

    {:ok, decoded} =
      :fixture_decoder
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()
      |> MMDB2Decoder.pipe_lookup({1, 1, 1, 0}, options)

    assert decoded[:array] == [1, 2, 3]
    assert decoded[:boolean] == true
    assert decoded[:bytes] == <<0, 0, 0, 42>>
    assert decoded[:double] == 42
    assert decoded[:float] == 1
    assert decoded[:int32] == -1 * :math.pow(2, 28)
    assert decoded[:map] == %{mapX: %{arrayX: [7, 8, 9], utf8_stringX: "hello"}}
    assert decoded[:uint16] == 100
    assert decoded[:uint32] == :math.pow(2, 28)
    assert decoded[:uint64] == 1 <<< 60
    assert decoded[:uint128] == 1 <<< 120
    assert decoded[:utf8_string] == "unicode! ☯ - ♫"
  end

  test "decoded values with map or list options are identical" do
    options = [
      double_precision: 6,
      float_precision: 6,
      map_keys: :atoms!
    ]

    {:ok, meta, tree, data} =
      :fixture_decoder
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    result_list = MMDB2Decoder.lookup({1, 1, 1, 0}, meta, tree, data, options)
    result_map = MMDB2Decoder.lookup({1, 1, 1, 0}, meta, tree, data, Map.new(options))

    assert result_list == result_map
  end

  test "decode double values with unset or nil precision identical" do
    {:ok, meta, tree, data} =
      :fixture_decoder
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    result_nil = MMDB2Decoder.lookup({1, 1, 1, 0}, meta, tree, data, %{double_precision: nil})
    result_unset = MMDB2Decoder.lookup({1, 1, 1, 0}, meta, tree, data, %{})

    assert result_nil == result_unset
  end

  test "decode float values with unset or nil precision identical" do
    {:ok, meta, tree, data} =
      :fixture_decoder
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    result_nil = MMDB2Decoder.lookup({1, 1, 1, 0}, meta, tree, data, %{float_precision: nil})
    result_unset = MMDB2Decoder.lookup({1, 1, 1, 0}, meta, tree, data, %{})

    assert result_nil == result_unset
  end

  test "decode map_keys as :atoms or :atoms! is identical" do
    {:ok, meta, tree, data} =
      :fixture_decoder
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    result_atoms = MMDB2Decoder.lookup({1, 1, 1, 0}, meta, tree, data, %{map_keys: :atoms})
    result_atoms! = MMDB2Decoder.lookup({1, 1, 1, 0}, meta, tree, data, %{map_keys: :atoms!})

    assert result_atoms == result_atoms!
  end

  test "decode map_keys as :string or nil is identical" do
    {:ok, meta, tree, data} =
      :fixture_decoder
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    result_nil = MMDB2Decoder.lookup({1, 1, 1, 0}, meta, tree, data, %{map_keys: nil})
    result_strings = MMDB2Decoder.lookup({1, 1, 1, 0}, meta, tree, data, %{map_keys: :strings})

    assert result_nil == result_strings
  end

  test "decoded values with default options" do
    {:ok, decoded} =
      :fixture_decoder
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()
      |> MMDB2Decoder.pipe_lookup({1, 1, 1, 0})

    assert %{
             "double" => 42.123456,
             "float" => 1.100000023841858,
             "map" => %{"mapX" => %{"arrayX" => [7, 8, 9], "utf8_stringX" => "hello"}}
           } = decoded
  end
end
