use Mix.Config

config :infrastructure, Infrastructure.Repository,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  database: "city_adventure_test",
  hostname: "localhost",
  password: "",
  port: 5433,
  types: Infrastructure.Repository.PostgresTypes,
  pool: Ecto.Adapters.SQL.Sandbox
