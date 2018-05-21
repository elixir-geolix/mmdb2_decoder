# MMDB2 File Format Decoder

## Setup

Add the module as a dependency to your `mix.exs` file:

```elixir
defp deps do
  [
    {:mmdb2_decoder, "~> 0.2.0"}
  ]
end
```

Depending on your elixir version you should also update your application list:

```elixir
def application do
  [
    included_applications: [:mmdb2_decoder]
  ]
end
```

## Usage

For more detailed examples and usage information please refer to the
inline documentation of the `MMDB2Decoder` module.

### Regular Flow

```elixir
database = File.read!("/path/to/database.mmdb")
{meta, tree, data} = MMDB2Decoder.parse_database(database)

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

A (minimal) benchmark script looking up random ip addresses is included:

```shell
mix run bench/lookup.exs

## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

License information about the supported
[MaxMind GeoIP2 Country](http://www.maxmind.com/en/country),
[MaxMind GeoIP2 City](http://www.maxmind.com/en/city) and
[MaxMind GeoLite2](http://dev.maxmind.com/geoip/geoip2/geolite2/) databases
can be found on their respective sites.
