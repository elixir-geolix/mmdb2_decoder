defmodule MMDB2Decoder.Benchmark.Database do
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
