defmodule CreatorApiWeb.Plugs.ParamLogger do
  require Logger

  def init(arg), do: arg

  def call(conn, _default) do
    Logger.metadata(app: "CreatorApi")

    Logger.info("Params: #{inspect(conn.params)}\n")

    conn
  end
end
