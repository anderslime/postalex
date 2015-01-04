defmodule Postalex.Mixfile do
  use Mix.Project

  def project do
    [app: :postalex,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  def application do
    [applications: [:logger, :couchex, :con_cache],
     mod: {Postalex, []}]
  end

  defp deps do
    [
      {:con_cache, "~> 0.6.0"},
      {:couchex, github: "ringling/couchex"},
      {:dotenv, "~> 0.0.4"},
      {:exprof, "0.1.3"}
    ]
  end
end
