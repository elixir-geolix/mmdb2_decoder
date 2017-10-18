defmodule MMDB2Decoder.DatabaseTest do
  use ExUnit.Case, async: true

  alias MMDB2Decoder.TestHelpers.Fixture

  test "ipv4 24 bit record size" do
    {meta, tree, data} =
      :fixture_ipv4_24
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert meta.record_size == 24

    result = MMDB2Decoder.lookup({1, 1, 1, 3}, meta, tree, data)

    assert result == %{ip: "1.1.1.2"}
  end

  test "ipv4 28 bit record size" do
    {meta, tree, data} =
      :fixture_ipv4_28
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert meta.record_size == 28

    result = MMDB2Decoder.lookup({1, 1, 1, 3}, meta, tree, data)

    assert result == %{ip: "1.1.1.2"}
  end

  test "ipv4 32 bit record size" do
    {meta, tree, data} =
      :fixture_ipv4_32
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert meta.record_size == 32

    result = MMDB2Decoder.lookup({1, 1, 1, 3}, meta, tree, data)

    assert result == %{ip: "1.1.1.2"}
  end

  test "ipv6 24 bit record size" do
    {meta, tree, data} =
      :fixture_ipv6_24
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert meta.record_size == 24

    result = MMDB2Decoder.lookup({0, 0, 0, 0, 0, 2, 0, 65}, meta, tree, data)

    assert result == %{ip: "::2:0:40"}
  end

  test "ipv6 28 bit record size" do
    {meta, tree, data} =
      :fixture_ipv6_28
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert meta.record_size == 28

    result = MMDB2Decoder.lookup({0, 0, 0, 0, 0, 2, 0, 65}, meta, tree, data)

    assert result == %{ip: "::2:0:40"}
  end

  test "ipv6 32 bit record size" do
    {meta, tree, data} =
      :fixture_ipv6_32
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert meta.record_size == 32

    result = MMDB2Decoder.lookup({0, 0, 0, 0, 0, 2, 0, 65}, meta, tree, data)

    assert result == %{ip: "::2:0:40"}
  end

  test "ipv6-in-ipv4 24 bit record size" do
    {meta, tree, data} =
      :fixture_ipv4_24
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert meta.record_size == 24

    result = MMDB2Decoder.lookup({0, 0, 0, 0, 0, 65535, 257, 257}, meta, tree, data)

    assert result == %{ip: "1.1.1.1"}
  end

  test "ipv6-in-ipv4 28 bit record size" do
    {meta, tree, data} =
      :fixture_ipv4_28
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert meta.record_size == 28

    result = MMDB2Decoder.lookup({0, 0, 0, 0, 0, 65535, 257, 257}, meta, tree, data)

    assert result == %{ip: "1.1.1.1"}
  end

  test "ipv6-in-ipv4 32 bit record size" do
    {meta, tree, data} =
      :fixture_ipv4_32
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert meta.record_size == 32

    result = MMDB2Decoder.lookup({0, 0, 0, 0, 0, 65535, 257, 257}, meta, tree, data)

    assert result == %{ip: "1.1.1.1"}
  end
end
