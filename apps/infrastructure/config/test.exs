use Mix.Config

config :media_storage,
  s3_access_key_id: "",
  s3_secret_access_key: "",
  s3_region: "",
  s3_bucket: ""

import_config("#{Mix.env()}.secret.exs")
