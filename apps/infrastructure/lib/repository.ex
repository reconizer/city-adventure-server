defmodule Infrastructure.Repository do
  use Ecto.Repo, otp_app: :infrastructure

  @start_apps [
    :postgrex,
    :ecto,
    :ssl
  ]

  @app :infrastructure

  @repos [
    Infrastructure.Repository
  ]

  def migrate do
    Application.load(@app)
    IO.puts("Starting dependencies..")
    # Start apps necessary for executing migrations
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    # Start the Repo(s) for myapp
    IO.puts("Starting repos..")
    Enum.each(@repos, & &1.start_link(pool_size: 1))

    # Run migrations
    IO.puts("Running migrations for #{@app}")
    Ecto.Migrator.run(Infrastructure.Repository, migrations_path(@app), :up, all: true)

    # Signal shutdown
    IO.puts("Success!")
    :init.stop()
  end

  def priv_dir(app), do: "#{:code.priv_dir(app)}"

  defp migrations_path(app), do: Path.join([priv_dir(app), "repository", "migrations"])
end
