use Mix.Config

config :infrastructure, Infrastructure.Repository,
  adapter: Ecto.Adapters.Postgres,
  username: "travis",
  database: "city_adventure_test",
  hostname: "localhost",
  password: "",
  port: 5432,
  types: Infrastructure.Repository.PostgresTypes,
  pool: Ecto.Adapters.SQL.Sandbox

config :media_storage,
  s3_access_key_id: "",
  s3_secret_access_key: "",
  s3_region: "",
  s3_bucket: ""

config :infrastructure, :asset_bucket, "gameinn-2-assets"
