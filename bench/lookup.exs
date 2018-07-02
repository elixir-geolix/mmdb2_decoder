defmodule MMDB2Decoder.Benchmark.Lookup do
  def run() do
    database =
      [Geolix.TestData.dir(:mmdb2), "Benchmark.mmdb"]
      |> Path.join()
      |> Path.expand()

    case File.exists?(database) do
      true -> run_benchmark(database)
      false -> IO.warn("Expected database not found at #{database}")
    end
  end

  defp run_benchmark(database) do
    {meta, tree, data} =
      database
      |> File.read!()
      |> MMDB2Decoder.parse_database()

    {:ok, lookup_ipv4} = :inet.parse_address('1.1.1.1')
    {:ok, lookup_ipv4_in_ipv6} = :inet.parse_address('::1.1.1.1')

    Benchee.run(
      %{
        "IPv4 in IPV6 lookup" => fn ->
          MMDB2Decoder.lookup(lookup_ipv4_in_ipv6, meta, tree, data)
        end,
        "IPv4 lookup" => fn ->
          MMDB2Decoder.lookup(lookup_ipv4, meta, tree, data)
        end
      },
      formatter_options: %{console: %{comparison: false}},
      warmup: 2,
      time: 10
    )
  end
end

MMDB2Decoder.Benchmark.Lookup.run()
