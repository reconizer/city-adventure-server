defmodule Domain.MixProject do
  use Mix.Project

  def project do
    [
      app: :domain,
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
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:infrastructure, in_umbrella: true},
      {:joken, "~> 1.5"},
      {:comeonin, "~> 4.1"},
      {:bcrypt_elixir, "~> 0.12"},
      {:ex_machina, "~> 2.2", only: :test}
    ]
  end
end
