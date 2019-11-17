defmodule MMDB2Decoder.ExclamationMethodEqualityTest do
  use ExUnit.Case, async: true

  alias MMDB2Decoder.TestHelpers.Fixture

  test "find_pointer!/3 equals find_pointer/3" do
    {:ok, meta, tree, _} =
      :fixture_ipv4_24
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    result_bang = MMDB2Decoder.find_pointer!({1, 1, 1, 3}, meta, tree)
    result_regular = MMDB2Decoder.find_pointer({1, 1, 1, 3}, meta, tree)

    assert {:ok, result_bang} == result_regular
  end

  test "lookup_pointer!/3 equals lookup_pointer/3" do
    {:ok, _, _, data} =
      :fixture_ipv4_24
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    result_bang = MMDB2Decoder.lookup_pointer!(0, data)
    result_regular = MMDB2Decoder.lookup_pointer(0, data)

    assert {:ok, result_bang} == result_regular
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
