# MMDB2 File Format Decoder

## Setup

Add the module as a dependency to your `mix.exs` file:

```elixir
defp deps do
  [{ :mmdb2_decoder, "~> 0.1.0" }]
end
```

Depending on your elixir version you should also update your applications to
include all necessary projects:

```elixir
def application do
  [applications: [:mmdb2_decoder]]
end
```

## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

License information about the supported
[MaxMind GeoIP2 Country](http://www.maxmind.com/en/country),
[MaxMind GeoIP2 City](http://www.maxmind.com/en/city) and
[MaxMind GeoLite2](http://dev.maxmind.com/geoip/geoip2/geolite2/) databases
can be found on their respective sites.
