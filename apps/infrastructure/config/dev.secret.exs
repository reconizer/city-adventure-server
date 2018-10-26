use Mix.Config

config :infrastructure, Infrastructure.Repository,
  username: "postgres",
  password: "postgres",
  database: "city_adventure",
  hostname: "localhost",
  port: 5433,
  pool_size: 10,
  types: Infrastructure.Repository.PostgresTypes
