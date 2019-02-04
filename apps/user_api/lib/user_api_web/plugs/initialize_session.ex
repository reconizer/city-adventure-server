defmodule UserApiWeb.Plugs.InitializeSession do
  import Plug.Conn

  def init(opts), do: opts

  def call(%Plug.Conn{assigns: %{user_id: user_id}} = conn, _default) do
    Session.construct()
    |> Session.update_context(conn.params)
    |> Session.update_context(%{"user_id" => user_id})
    |> case do
      session -> conn |> assign(:session, session)
    end
  end

  def call(%Plug.Conn{} = conn, _default) do
    Session.construct()
    |> Session.update_context(conn.params)
    |> case do
      session -> conn |> assign(:session, session)
    end
  end
end
