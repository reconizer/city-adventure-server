use Mix.Config

config :infrastructure, Infrastructure.Repository,
  adapter: Ecto.Adapters.Postgres,
<<<<<<< HEAD
  username: "developer",
  password: "developer",
  database: "gameinn_2",
  hostname: "localhost",
  port: 5433,
  pool_size: 10,
  types: Infrastructure.Repository.PostgresTypes
=======
  username: "postgres",
  password: "postgres",
  database: "city_adventure",
  hostname: "localhost",
  port: 5432,
  pool_size: 10,
  types: Infrastructure.Repository.PostgresTypes
>>>>>>> 7ab9b7c4857715bbb28d0e269f0092cc171fe33f
