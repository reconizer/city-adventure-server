defmodule Worker.MixProject do
  use Mix.Project

  def project do
    [
      app: :worker,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :ssl],
      mod: {Worker.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:infrastructure, in_umbrella: true},
      {:gen_stage, "~> 0.14"},
      {:ex_aws, "~> 2.1.1", override: true},
      {:ex_aws_sqs, "~> 2.0.1"},
      {:poison, "~> 3.0"},
      {:hackney, "~> 1.15"},
      {:sweet_xml, "~> 0.6"}
    ]
  end
end
