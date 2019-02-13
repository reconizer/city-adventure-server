defmodule UserApiWeb.PingController do
  use UserApiWeb, :controller

  def ping(conn, _) do
    render(conn, "ping.json", %{})
  end
end
