defmodule TinyEctoHelperMySQL.MixProject do
  use Mix.Project

  @version "1.0.1"
  @link "https://github.com/hykw/tiny_ecto_helper_mysql"

  def project do
    [
      app: :tiny_ecto_helper_mysql,
      version: @version,
      elixir: "~> 1.6",
      deps: deps(),

      # hex
      description: "Tiny Ecto Helper for MySQL",
      package: package(),
      source_url: @link,
      homepage_url: @link
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:ecto, ">= 0.0.0"},
      {:ecto_sql, ">= 0.0.0"}
    ]
  end

  defp package do
    [
      maintainers: ["Hitoshi Hayakawa"],
      licenses: ["MIT"],
      links: %{"GitHub" => @link},
      files: ~w(lib mix.exs README.md)
    ]
  end
end
