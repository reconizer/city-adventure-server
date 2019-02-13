defmodule CreatorApiWeb.PingController do
  use CreatorApiWeb, :silent_controller

  def ping(conn, _) do
    render(conn, "ping.json", %{})
  end
end
