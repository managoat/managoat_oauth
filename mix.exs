defmodule Managoat.OAuth.MixProject do
  use Mix.Project

  @version "0.1.1"
  @source_url "https://github.com/managoat/managoat_oauth"

  def project do
    [
      app: :managoat_oauth,
      version: @version,
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description:
        "OAuth 2.0 authorization code + PKCE and device grant state machine for public clients, behind a host behaviour that mints the token.",
      package: package(),
      source_url: @source_url,
      docs: docs(),
      dialyzer: dialyzer(),
      test_coverage: [
        # The grant state machine, client registry, config loader and migration
        # currently measure 96.20%, driven through both an instance and the
        # direct facade against the library's own Postgres database. The
        # remaining misses are collision retries and concurrency-loser paths;
        # keep a little headroom for a real branch and never lower this gate.
        summary: [threshold: 96]
      ]
    ]
  end

  def application do
    [extra_applications: [:logger, :crypto]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Tooling for the repository, not the package: docs for hexdocs.pm (built
      # by `mix hex.publish`), credo and dialyzer for CI. dialyxir is pinned to
      # the commit that added OTP 28 support; 1.4.7 crashes on OTP 28 warnings.
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir,
       github: "jeremyjh/dialyxir",
       ref: "3553678f4d69281ac6db61034bcf35bcb30cfd78",
       only: [:dev, :test],
       runtime: false},
      # Schemas, queries and the migration helpers. The host supplies the
      # repo; this library starts none.
      {:ecto_sql, "~> 3.13"},
      # The library's own tests run against Postgres; a consumer brings the
      # adapter its repo uses.
      {:postgrex, ">= 0.0.0", only: :test}
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url, "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md"},
      files: ~w(lib mix.exs README.md CHANGELOG.md LICENSE NOTICE)
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md"],
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end

  defp dialyzer do
    [
      ignore_warnings: ".dialyzer_ignore.exs",
      # A fixed path so CI can cache the PLT across runs.
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end
end
