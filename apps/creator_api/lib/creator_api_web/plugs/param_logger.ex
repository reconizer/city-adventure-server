defmodule CreatorApiWeb.Plugs.ParamLogger do
  require Logger

  def init(arg), do: arg

  def call(conn, _default) do
    Logger.metadata(app: "CreatorApi")

    Logger.info([
      "\n",
      "  Parameters: #{inspect(conn.params)}\n",
      "  Pipelines: #{inspect(conn.private.phoenix_pipelines)}"
    ])

    conn
  end
end
