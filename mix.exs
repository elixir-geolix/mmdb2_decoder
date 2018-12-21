defmodule MMDB2Decoder.Mixfile do
  use Mix.Project

  @url_github "https://github.com/elixir-geolix/mmdb2_decoder"

  def project do
    [
      app: :mmdb2_decoder,
      name: "MMDB2 Decoder",
      version: "0.4.0-dev",
      elixir: "~> 1.3",
      aliases: aliases(),
      deps: deps(),
      description: "MMDB2 File Format Decoder",
      docs: docs(),
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      preferred_cli_env: [
        "bench.database": :bench,
        "bench.lookup": :bench,
        "bench.parse": :bench,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.travis": :test
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
      {:benchee, "~> 0.13", only: :bench, runtime: false},
      {:credo, "~> 1.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test, runtime: false},
      {:geolix_testdata, "~> 0.3.0", only: :bench, runtime: false},
      {:hackney, "~> 1.0", only: :test, runtime: false}
    ]
  end

  defp docs do
    [
      main: "MMDB2Decoder",
      source_ref: "master",
      source_url: @url_github
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/helpers"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    %{
      files: ["CHANGELOG.md", "LICENSE", "mix.exs", "README.md", "lib"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => @url_github},
      maintainers: ["Marc Neudert"]
    }
  end
end
