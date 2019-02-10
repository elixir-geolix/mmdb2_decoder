defmodule MMDB2Decoder.Benchmark.Parse do
  def run do
    database = determine_database()

    case File.exists?(database) do
      true ->
        IO.puts("Using database at #{database}\n")
        run_benchmark(database)

      false ->
        IO.warn("Expected database not found at #{database}")
    end
  end

  defp determine_database do
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

    {:ok, parse_array_1} = :inet.parse_address('2.0.4.1')
    {:ok, parse_array_10} = :inet.parse_address('2.0.4.10')

    {:ok, parse_map_1} = :inet.parse_address('2.7.0.1')
    {:ok, parse_map_10} = :inet.parse_address('2.7.0.10')

    {:ok, parse_binary_1} = :inet.parse_address('2.2.0.1')
    {:ok, parse_binary_42} = :inet.parse_address('2.2.0.2')
    {:ok, parse_binary_420} = :inet.parse_address('2.2.0.3')
    {:ok, parse_binary_84000} = :inet.parse_address('2.2.0.4')

    Benchee.run(
      %{
        "Parsing: Array (1 element)" => fn ->
          MMDB2Decoder.lookup(parse_array_1, meta, tree, data)
        end,
        "Parsing: Array (10 elements)" => fn ->
          MMDB2Decoder.lookup(parse_array_10, meta, tree, data)
        end,
        "Parsing: Binary (1 character)" => fn ->
          MMDB2Decoder.lookup(parse_binary_1, meta, tree, data)
        end,
        "Parsing: Binary (42 character)" => fn ->
          MMDB2Decoder.lookup(parse_binary_42, meta, tree, data)
        end,
        "Parsing: Binary (420 character)" => fn ->
          MMDB2Decoder.lookup(parse_binary_420, meta, tree, data)
        end,
        "Parsing: Binary (84000 character)" => fn ->
          MMDB2Decoder.lookup(parse_binary_84000, meta, tree, data)
        end,
        "Parsing: Map (nested 1 level)" => fn ->
          MMDB2Decoder.lookup(parse_map_1, meta, tree, data)
        end,
        "Parsing: Map (nested 10 levels)" => fn ->
          MMDB2Decoder.lookup(parse_map_10, meta, tree, data)
        end
      },
      formatter_options: %{console: %{comparison: false}},
      warmup: 2,
      time: 10
    )
  end
end

MMDB2Decoder.Benchmark.Parse.run()
