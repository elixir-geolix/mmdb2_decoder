defmodule MMDB2Decoder.TestHelpers.Fixture do
  @moduledoc false

  alias Geolix.TestData.MMDB2Fixture

  @path Path.join([__DIR__, "../fixtures"])
  @fixtures [
    {:fixture_decoder, "MaxMind-DB-test-decoder.mmdb"},
    {:fixture_ipv4_24, "MaxMind-DB-test-ipv4-24.mmdb"},
    {:fixture_ipv4_28, "MaxMind-DB-test-ipv4-28.mmdb"},
    {:fixture_ipv4_32, "MaxMind-DB-test-ipv4-32.mmdb"},
    {:fixture_ipv6_24, "MaxMind-DB-test-ipv6-24.mmdb"},
    {:fixture_ipv6_28, "MaxMind-DB-test-ipv6-28.mmdb"},
    {:fixture_ipv6_32, "MaxMind-DB-test-ipv6-32.mmdb"},
    {:fixture_broken_pointers, "MaxMind-DB-test-broken-pointers-24.mmdb"},
    {:fixture_no_ipv4_search_tree, "MaxMind-DB-no-ipv4-search-tree.mmdb"}
  ]

  Enum.each(@fixtures, fn {name, file} ->
    def contents(unquote(name)) do
      MMDB2Fixture.contents(unquote(file), @path)
    end
  end)

  def download do
    Enum.each(@fixtures, fn {_name, file} ->
      MMDB2Fixture.download(file, @path)
    end)
  end
end
