use Mix.Config

config :infrastructure, Infrastructure.Repository,
  adapter: Ecto.Adapters.Postgres,
  username: "developer",
  password: "developer",
  database: "gameinn_2_test",
  hostname: "localhost",
  port: 5432,
  types: Infrastructure.Repository.PostgresTypes,
  pool: Ecto.Adapters.SQL.Sandbox

config :infrastructure, :asset_bucket, "gameinn-2-assets"
