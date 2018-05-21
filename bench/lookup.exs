defmodule MMDB2Decoder.Benchmark do
  def run() do
    database =
      [__DIR__, "../data/GeoLite2-City.mmdb"]
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

    Benchee.run(
      %{
        "random ip lookup" => fn ->
          {
            :rand.uniform(255),
            :rand.uniform(255),
            :rand.uniform(255),
            :rand.uniform(255)
          }
          |> MMDB2Decoder.lookup(meta, tree, data)
        end
      },
      warmup: 2,
      time: 30
    )
  end
end

MMDB2Decoder.Benchmark.run()
