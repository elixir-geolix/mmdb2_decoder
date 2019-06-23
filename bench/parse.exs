defmodule MMDB2Decoder.Benchmark.Parse do
  def run do
    {:ok, meta, tree, data} =
      :mmdb2
      |> Geolix.TestData.file("Benchmark.mmdb")
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
        "Parsing: Binary (42 characters)" => fn ->
          MMDB2Decoder.lookup(parse_binary_42, meta, tree, data)
        end,
        "Parsing: Binary (420 characters)" => fn ->
          MMDB2Decoder.lookup(parse_binary_420, meta, tree, data)
        end,
        "Parsing: Binary (84000 characters)" => fn ->
          MMDB2Decoder.lookup(parse_binary_84000, meta, tree, data)
        end,
        "Parsing: Map (nested 1 level, map_keys: :atoms)" => fn ->
          MMDB2Decoder.lookup(parse_map_1, meta, tree, data, map_keys: :atoms)
        end,
        "Parsing: Map (nested 1 level, map_keys: :strings)" => fn ->
          MMDB2Decoder.lookup(parse_map_1, meta, tree, data, map_keys: :strings)
        end,
        "Parsing: Map (nested 10 levels, map_keys: :atoms)" => fn ->
          MMDB2Decoder.lookup(parse_map_10, meta, tree, data, map_keys: :atoms)
        end,
        "Parsing: Map (nested 10 levels, map_keys: :strings)" => fn ->
          MMDB2Decoder.lookup(parse_map_10, meta, tree, data, map_keys: :strings)
        end
      },
      formatters: [{Benchee.Formatters.Console, comparison: false}],
      warmup: 2,
      time: 10
    )
  end
end

MMDB2Decoder.Benchmark.Parse.run()
