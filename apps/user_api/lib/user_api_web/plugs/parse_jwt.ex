defmodule UserApiWeb.Plugs.ParseJwt do
  import Plug.Conn

  def init(opts), do: opts

  def call(%Plug.Conn{} = conn, _default) do
    conn
    |> get_req_header("authorization")
    |> case do
      ["Bearer " <> ""] -> conn |> assign(:jwt, :error)
      ["Bearer " <> token] -> conn |> assign(:jwt, token)
      _ -> conn |> assign(:jwt, :error)
    end
  end
end
