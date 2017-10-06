defmodule MMDB2Decoder.Mixfile do
  use Mix.Project

  @url_github "https://github.com/elixir-geolix/mmdb2_decoder"

  def project do
    [ app:     :mmdb2_decoder,
      name:    "MMDB2 Decoder",
      version: "0.1.0-dev",
      elixir:  "~> 1.3",
      deps:    deps(),

      preferred_cli_env: [
        coveralls:          :test,
        'coveralls.detail': :test,
        'coveralls.travis': :test
      ],

      description:   "MMDB2 File Format Decoder",
      docs:          docs(),
      package:       package(),
      test_coverage: [ tool: ExCoveralls ]]
  end

  def application do
    [ applications: [ :logger ]]
  end

  defp deps do
    [{ :ex_doc,      ">= 0.0.0", only: :dev },
     { :excoveralls, "~> 0.7",   only: :test }]
  end

  defp docs do
    [ extras:     [ "CHANGELOG.md", "README.md" ],
      main:       "readme",
      source_ref: "master",
      source_url: @url_github ]
  end

  defp package do
    %{ files:       [ "CHANGELOG.md", "LICENSE", "mix.exs", "README.md", "lib" ],
       licenses:    [ "Apache 2.0" ],
       links:       %{ "GitHub" => @url_github },
       maintainers: [ "Marc Neudert" ] }
  end
end
