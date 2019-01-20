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

    assert result == %{ip: "1.1.1.2"}
  end

  test "ipv4 28 bit record size" do
    {:ok, meta, tree, data} =
      :fixture_ipv4_28
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert meta.record_size == 28

    {:ok, result} = MMDB2Decoder.lookup({1, 1, 1, 3}, meta, tree, data)

    assert result == %{ip: "1.1.1.2"}
  end

  test "ipv4 32 bit record size" do
    {:ok, meta, tree, data} =
      :fixture_ipv4_32
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert meta.record_size == 32

    {:ok, result} = MMDB2Decoder.lookup({1, 1, 1, 3}, meta, tree, data)

    assert result == %{ip: "1.1.1.2"}
  end

  test "ipv6 24 bit record size" do
    {:ok, meta, tree, data} =
      :fixture_ipv6_24
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert meta.record_size == 24

    {:ok, result} = MMDB2Decoder.lookup({0, 0, 0, 0, 0, 2, 0, 65}, meta, tree, data)

    assert result == %{ip: "::2:0:40"}
  end

  test "ipv6 28 bit record size" do
    {:ok, meta, tree, data} =
      :fixture_ipv6_28
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert meta.record_size == 28

    {:ok, result} = MMDB2Decoder.lookup({0, 0, 0, 0, 0, 2, 0, 65}, meta, tree, data)

    assert result == %{ip: "::2:0:40"}
  end

  test "ipv6 32 bit record size" do
    {:ok, meta, tree, data} =
      :fixture_ipv6_32
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert meta.record_size == 32

    {:ok, result} = MMDB2Decoder.lookup({0, 0, 0, 0, 0, 2, 0, 65}, meta, tree, data)

    assert result == %{ip: "::2:0:40"}
  end

  test "ipv6-in-ipv4 24 bit record size" do
    {:ok, meta, tree, data} =
      :fixture_ipv4_24
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert meta.record_size == 24

    {:ok, result} = MMDB2Decoder.lookup({0, 0, 0, 0, 0, 65_535, 257, 257}, meta, tree, data)

    assert result == %{ip: "1.1.1.1"}
  end

  test "ipv6-in-ipv4 28 bit record size" do
    {:ok, meta, tree, data} =
      :fixture_ipv4_28
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert meta.record_size == 28

    {:ok, result} = MMDB2Decoder.lookup({0, 0, 0, 0, 0, 65_535, 257, 257}, meta, tree, data)

    assert result == %{ip: "1.1.1.1"}
  end

  test "ipv6-in-ipv4 32 bit record size" do
    {:ok, meta, tree, data} =
      :fixture_ipv4_32
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert meta.record_size == 32

    {:ok, result} = MMDB2Decoder.lookup({0, 0, 0, 0, 0, 65_535, 257, 257}, meta, tree, data)

    assert result == %{ip: "1.1.1.1"}
  end

  test "decoded values" do
    {:ok, decoded} =
      :fixture_decoder
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()
      |> MMDB2Decoder.pipe_lookup({1, 1, 1, 0})

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

  test "lookup!/4 equals lookup/4" do
    {:ok, meta, tree, data} =
      :fixture_ipv4_24
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    result_bang = MMDB2Decoder.lookup!({1, 1, 1, 3}, meta, tree, data)
    result_regular = MMDB2Decoder.lookup({1, 1, 1, 3}, meta, tree, data)

    assert {:ok, result_bang} == result_regular
  end

  test "pipe_lookup!/2 equals pipe_lookup/2" do
    database =
      :fixture_ipv4_24
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    result_bang = MMDB2Decoder.pipe_lookup!(database, {1, 1, 1, 3})
    result_regular = MMDB2Decoder.pipe_lookup(database, {1, 1, 1, 3})

    assert {:ok, result_bang} == result_regular
  end
end
