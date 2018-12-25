defmodule MMDB2Decoder.Benchmark.Lookup do
  def run() do
    database = determine_database()

    case File.exists?(database) do
      true ->
        IO.puts("Using database at #{database}\n")
        run_benchmark(database)

      false ->
        IO.warn("Expected database not found at #{database}")
    end
  end

  defp determine_database() do
    case System.argv() do
      [] ->
        [Geolix.TestData.dir(:mmdb2), "Benchmark.mmdb"]
        |> Path.join()
        |> Path.expand()

      [path] ->
        Path.expand(path)
    end
  end

  defp run_benchmark(database) do
    {:ok, meta, tree, data} =
      database
      |> File.read!()
      |> MMDB2Decoder.parse_database()

    {:ok, lookup_ipv4} = :inet.parse_address('1.1.1.1')
    {:ok, lookup_ipv4_in_ipv6} = :inet.parse_address('::1.1.1.1')

    Benchee.run(
      %{
        "Lookup: IPv4" => fn ->
          MMDB2Decoder.lookup(lookup_ipv4, meta, tree, data)
        end,
        "Lookup: IPv4 in IPV6" => fn ->
          MMDB2Decoder.lookup(lookup_ipv4_in_ipv6, meta, tree, data)
        end
      },
      formatter_options: %{console: %{comparison: false}},
      warmup: 2,
      time: 10
    )
  end
end

MMDB2Decoder.Benchmark.Lookup.run()
