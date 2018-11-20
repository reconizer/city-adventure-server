use Mix.Config

config :logger, level: :info

config :infrastructure, Infrastructure.Repository,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "city_adventure",
  hostname: "localhost",
  port: 5432,
  pool_size: 10,
  types: Infrastructure.Repository.PostgresTypes
