use Mix.Config

config :infrastructure, Infrastructure.Repository,
  adapter: Ecto.Adapters.Postgres,
  username: "developer",
  password: "developer",
  database: "gameinn_2",
  hostname: "localhost",
  port: 5433,
  pool_size: 10,
  types: Infrastructure.Repository.PostgresTypes