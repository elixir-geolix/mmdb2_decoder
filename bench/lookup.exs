defmodule MMDB2Decoder.Benchmark.Lookup do
  def run do
    {:ok, meta, tree, data} =
      :mmdb2
      |> Geolix.TestData.file("Benchmark.mmdb")
      |> File.read!()
      |> MMDB2Decoder.parse_database()

    {:ok, lookup_ipv4} = :inet.parse_address('1.1.1.1')
    {:ok, lookup_ipv4_in_ipv6} = :inet.parse_address('::1.1.1.1')

    Benchee.run(
      %{
        "Lookup: IPv4" => fn ->
          MMDB2Decoder.lookup(lookup_ipv4, meta, tree, data)
        end,
        "Lookup: IPv4 in IPv6" => fn ->
          MMDB2Decoder.lookup(lookup_ipv4_in_ipv6, meta, tree, data)
        end
      },
      formatters: [{Benchee.Formatters.Console, comparison: false}],
      warmup: 2,
      time: 10
    )
  end
end

MMDB2Decoder.Benchmark.Lookup.run()
