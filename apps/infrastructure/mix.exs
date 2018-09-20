defmodule Infrastructure.MixProject do
  use Mix.Project

  def project do
    [
      app: :infrastructure,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :postgrex, :ecto, :poison],
      mod: {Infrastructure, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:postgrex, ">= 0.0.0"},
      {:ecto, "~> 2.2.10"},
      {:geo, "~> 2.0"},
      {:gettext, "~> 0.11"},
      {:poison, "~> 3.0"},
      {:geo_postgis, "~> 1.1"}
    ]
  end
end
