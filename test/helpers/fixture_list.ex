defmodule MMDB2Decoder.TestHelpers.FixtureList do
  @moduledoc false

  @baseurl "https://raw.githubusercontent.com/maxmind/MaxMind-DB/master/test-data"
  @fixtures [
    {:fixture_decoder, "MaxMind-DB-test-decoder.mmdb", "#{@baseurl}/MaxMind-DB-test-decoder.mmdb"},
    {:fixture_ipv4_24, "MaxMind-DB-test-ipv4-24.mmdb", "#{@baseurl}/MaxMind-DB-test-ipv4-24.mmdb"},
    {:fixture_ipv4_28, "MaxMind-DB-test-ipv4-28.mmdb", "#{@baseurl}/MaxMind-DB-test-ipv4-28.mmdb"},
    {:fixture_ipv4_32, "MaxMind-DB-test-ipv4-32.mmdb", "#{@baseurl}/MaxMind-DB-test-ipv4-32.mmdb"},
    {:fixture_ipv6_24, "MaxMind-DB-test-ipv6-24.mmdb", "#{@baseurl}/MaxMind-DB-test-ipv6-24.mmdb"},
    {:fixture_ipv6_28, "MaxMind-DB-test-ipv6-28.mmdb", "#{@baseurl}/MaxMind-DB-test-ipv6-28.mmdb"},
    {:fixture_ipv6_32, "MaxMind-DB-test-ipv6-32.mmdb", "#{@baseurl}/MaxMind-DB-test-ipv6-32.mmdb"},
    {
      :fixture_broken_pointers,
      "MaxMind-DB-test-broken-pointers-24.mmdb",
      "#{@baseurl}/MaxMind-DB-test-broken-pointers-24.mmdb"
    },
    {
      :fixture_no_ipv4_search_tree,
      "MaxMind-DB-no-ipv4-search-tree.mmdb",
      "#{@baseurl}/MaxMind-DB-no-ipv4-search-tree.mmdb"
    }
  ]

  @doc """
  Returns a list of all available/downloaded fixtures.

  Each returned entry consists of the following values:

      {
        :name_as_atom,
        "local_filename.mmdb",
        "remote_url"
      }
  """
  @spec get() :: list
  def get(), do: @fixtures

  Enum.each(@fixtures, fn {name, file, _} ->
    def fixture_name(unquote(name)), do: unquote(file)
  end)
end
