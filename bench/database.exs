defmodule MMDB2Decoder.Benchmark.Database do
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
    content = File.read!(database)

    Benchee.run(
      %{
        "Parse Database" => fn ->
          MMDB2Decoder.parse_database(content)
        end
      },
      formatter_options: %{console: %{comparison: false}},
      warmup: 2,
      time: 10
    )
  end
end

MMDB2Decoder.Benchmark.Database.run()
