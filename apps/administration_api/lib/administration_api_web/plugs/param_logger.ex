defmodule AdministrationApiWeb.Plugs.ParamLogger do
  require Logger

  def init(arg), do: arg

  def call(conn, _default) do
    Logger.info([
      "\n",
      "  Parameters: #{inspect(conn.params)}\n",
      "  Pipelines: #{inspect(conn.private.phoenix_pipelines)}"
    ])
    conn
  end
end
