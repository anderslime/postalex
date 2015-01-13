defmodule Postalex.Mixfile do
  use Mix.Project

  def project do
    [app: :postalex,
     version: "0.0.2",
     elixir: "~> 1.0",
     deps: deps]
  end

  def application do
    [applications: [:logger, :couchex, :con_cache, :httpotion, :poison],
     mod: {Postalex, []}]
  end

  defp deps do
    [
      {:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.1.0"},
      {:httpotion, "~> 1.0.0"},
      {:con_cache, "~> 0.6.0"},
      {:couchex, github: "ringling/couchex"},
      {:poison, github: "devinus/poison"},
      {:dotenv, "~> 0.0.4"},
      {:exprof, "0.1.3"}
    ]
  end
end
