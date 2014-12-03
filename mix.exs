defmodule Blog.Mixfile do
  use Mix.Project

  def project do
    [app: :blog,
     version: "0.0.1",
     elixir: "~> 1.0.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: elixir_apps,
     mod: {Blog, []}]
  end

  defp elixir_apps do
    [:logger, :postgrex, :ecto, :cowboy, :plug]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [{:postgrex, ">= 0.0.0"},
     {:ecto,     "~> 0.2.5"},
     {:cowboy,   "~> 1.0.0"},
     {:plug,     "~> 0.8.2"},
     {:poison,   "~> 1.2.0"},
     {:relax,    github: "AgilionApps/relax"}]
  end
end
