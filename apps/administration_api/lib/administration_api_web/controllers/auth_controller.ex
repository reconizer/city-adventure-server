defmodule AdministrationApiWeb.AuthController do
  use AdministrationApiWeb, :controller

  alias AdministrationApiWeb.AuthContract
  alias Domain.Administration

  def login(conn, params) do
    AuthContract.login(conn, params)
    |> Administration.User.Repository.get_for_authentication()
    |> AdministrationApi.Token.create()
    |> case do
      {:ok, token} ->
        conn
        |> render("login.json", %{token: token})

      error ->
        handle_error(conn, error)
    end
  end
end
