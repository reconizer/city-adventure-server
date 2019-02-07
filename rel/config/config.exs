use Mix.Config

db_port = String.to_integer(System.get_env("DATABASE_PORT"))

config :infrastructure, Infrastructure.Repository,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DATABASE_USER"),
  password: System.get_env("DATABASE_PASSWORD"),
  database: System.get_env("DATABASE_NAME"),
  hostname: System.get_env("DATABASE_HOST"),
  port: db_port,
  types: Infrastructure.Repository.PostgresTypes,
  pool: Ecto.Adapters.SQL.Sandbox
