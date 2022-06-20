defmodule MMDB2Decoder.MixProject do
  use Mix.Project

  @url_github "https://github.com/elixir-geolix/mmdb2_decoder"

  def project do
    [
      app: :mmdb2_decoder,
      name: "MMDB2 Decoder",
      version: "3.0.1",
      elixir: "~> 1.7",
      aliases: aliases(),
      deps: deps(),
      description: "MMDB2 File Format Decoder",
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
      {:benchee, "~> 1.0", only: :bench, runtime: false},
      {:credo, "~> 1.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.14.0", only: :test, runtime: false},
      {:geolix_testdata, "~> 0.5.1", only: [:bench, :test], runtime: false}
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
      plt_file: {:no_warn, "plts/dialyzer.plt"}
    ]
  end

  defp docs do
    [
      main: "MMDB2Decoder",
      source_ref: "v3.0.1",
      source_url: @url_github
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/helpers"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    %{
      files: ["CHANGELOG.md", "LICENSE", "mix.exs", "README.md", "lib"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => @url_github}
    }
  end
end
