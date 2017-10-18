defmodule MMDB2Decoder.ErrorTest do
  use ExUnit.Case, async: true

  alias MMDB2Decoder.TestHelpers.Fixture

  test "broken pointers" do
    {meta, tree, data} =
      :fixture_broken_pointers
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert nil == MMDB2Decoder.lookup({1, 1, 1, 32}, meta, tree, data)
  end

  test "no ipv4 search tree" do
    {meta, tree, data} =
      :fixture_no_ipv4_search_tree
      |> Fixture.contents()
      |> MMDB2Decoder.parse_database()

    assert nil == MMDB2Decoder.lookup({1, 1, 1, 3}, meta, tree, data)
  end
end
