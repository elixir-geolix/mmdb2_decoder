# MMDB2 File Format Decoder

## Setup

Add the module as a dependency to your `mix.exs` file:

```elixir
defp deps do
  [
    # ...
    {:mmdb2_decoder, "~> 3.0"},
    # ...
  ]
end
```

## Usage

For more detailed examples and usage information please refer to the inline documentation of the `MMDB2Decoder` module.

### Regular Flow

```elixir
database = File.read!("/path/to/database.mmdb")
{:ok, meta, tree, data} = MMDB2Decoder.parse_database(database)

{:ok, ip} = :inet.parse_address(String.to_charlist("8.8.8.8"))

MMDB2Decoder.lookup(ip, meta, tree, data)
```

### Direct Piping

```elixir
"/path/to/database.mmdb"
|> File.read!()
|> MMDB2Decoder.parse_database()
|> MMDB2Decoder.pipe_lookup({8, 8, 8, 8})
```

## Benchmark

Several (minimal) benchmark scripts are included. Please refer to the Mixfile or `mix help` output for their names.

## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

License information about the supported [MaxMind GeoIP2 Country](https://www.maxmind.com/en/geoip2-country-database), [MaxMind GeoIP2 City](https://www.maxmind.com/en/geoip2-city) and [MaxMind GeoLite2](https://dev.maxmind.com/geoip/geoip2/geolite2/) databases can be found on their respective sites.
