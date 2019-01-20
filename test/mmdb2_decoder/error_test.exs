defmodule MMDB2Decoder.ErrorTest do
  use ExUnit.Case, async: true

  alias MMDB2Decoder.TestHelpers.Fixture

  test "error result for pipe_lookup!/2" do
    assert_raise RuntimeError, "parse error", fn ->
      MMDB2Decoder.pipe_lookup!({:error, "parse error"}, :ignored)
    end
  end

  test "broken pointers" do
    assert {:ok, nil} ==
             :fixture_broken_pointers
             |> Fixture.contents()
             |> MMDB2Decoder.parse_database()
             |> MMDB2Decoder.pipe_lookup({1, 1, 1, 32})
  end

  test "no ipv4 search tree" do
    assert {:ok, nil} ==
             :fixture_no_ipv4_search_tree
             |> Fixture.contents()
             |> MMDB2Decoder.parse_database()
             |> MMDB2Decoder.pipe_lookup({1, 1, 1, 3})
  end
end
