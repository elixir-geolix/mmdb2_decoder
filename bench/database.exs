content =
  :mmdb2
  |> Geolix.TestData.file("Benchmark.mmdb")
  |> File.read!()

Benchee.run(
  %{
    "Parse Database" => fn ->
      MMDB2Decoder.parse_database(content)
    end
  },
  formatters: [{Benchee.Formatters.Console, comparison: false}],
  warmup: 2,
  time: 10
)
