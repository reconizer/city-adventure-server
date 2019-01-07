use Mix.Config

config :infrastructure, Infrastructure.Repository,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "gameinn_2_test",
  hostname: "localhost",
  port: 5433,
  types: Infrastructure.Repository.PostgresTypes,
  pool: Ecto.Adapters.SQL.Sandbox
