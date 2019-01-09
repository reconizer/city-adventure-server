use Mix.Config

config :worker, :file_upload_queue_name, ""
config :worker, :asset_bucket, ""
config :worker, :conversion_queue_name, ""

config :ex_aws, :sqs,
  access_key_id: "",
  secret_access_key: "",
  region: ""

config :ex_aws, :s3,
  access_key_id: "",
  secret_access_key: "",
  region: ""

import_config "#{Mix.env()}.secret.exs"
