{meta, tree, data} =
  [__DIR__, "../data/GeoLite2-City.mmdb"]
  |> Path.join()
  |> Path.expand()
  |> File.read!()
  |> MMDB2Decoder.parse_database()

Benchee.run(
  %{
    "lookup" => fn ->
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
