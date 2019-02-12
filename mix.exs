defmodule CityAdventure.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:distillery, "~> 2.0"},
      {:ex_doc, "~> 0.19.3"},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false}
    ]
  end
end
