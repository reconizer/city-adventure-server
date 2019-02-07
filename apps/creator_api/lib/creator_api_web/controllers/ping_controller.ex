defmodule CreatorApiWeb.PingController do
  use CreatorApiWeb, :controller

  def ping(conn, _) do
    render(conn, "ping.json", %{})
  end
end
