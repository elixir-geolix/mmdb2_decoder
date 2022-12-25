defmodule MMDB2Decoder.MixProject do
  use Mix.Project

  @url_github "https://github.com/elixir-geolix/mmdb2_decoder"
  @url_changelog "https://hexdocs.pm/mmdb2_decoder/changelog.html"
  @version "3.1.0-dev"

  def project do
    [
      app: :mmdb2_decoder,
      name: "MMDB2 Decoder",
      description: "MMDB2 File Format Decoder",
      version: @version,
      elixir: "~> 1.7",
      aliases: aliases(),
      deps: deps(),
      dialyzer: dialyzer(),
      docs: docs(),
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      preferred_cli_env: [
        "bench.database": :bench,
        "bench.lookup": :bench,
        "bench.parse": :bench,
        coveralls: :test,
        "coveralls.detail": :test
      ],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  defp aliases() do
    [
      "bench.database": ["run bench/database.exs"],
      "bench.lookup": ["run bench/lookup.exs"],
      "bench.parse": ["run bench/parse.exs"]
    ]
  end

  defp deps do
    [
      {:benchee, "~> 1.1", only: :bench, runtime: false},
      {:credo, "~> 1.6", only: :dev, runtime: false},
      {:dialyxir, "~> 1.2", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.15.0", only: :test, runtime: false},
      {:geolix_testdata, "~> 0.6.0", only: [:bench, :test], runtime: false}
    ]
  end

  defp dialyzer do
    [
      flags: [
        :error_handling,
        :underspecs,
        :unmatched_returns
      ],
      plt_core_path: "plts",
      plt_local_path: "plts"
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md",
        LICENSE: [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "MMDB2Decoder",
      source_ref: "v#{@version}",
      source_url: @url_github,
      formatters: ["html"]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/helpers"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      files: ["CHANGELOG.md", "LICENSE", "mix.exs", "README.md", "lib"],
      licenses: ["Apache-2.0"],
      links: %{
        "Changelog" => @url_changelog,
        "GitHub" => @url_github
      }
    ]
  end
end
