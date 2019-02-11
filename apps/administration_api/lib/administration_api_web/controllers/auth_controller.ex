defmodule AdministrationApiWeb.AuthController do
  use AdministrationApiWeb, :controller

  alias AdministrationApiWeb.AuthContract
  alias Domain.Administration

  def login(conn, params) do
    with {:ok, params} <- AuthContract.login(conn, params),
         {:ok, user} <- Administration.User.Repository.get_for_authentication(params),
         {:ok, token} <- AdministrationApi.Token.create(user.id) do
      conn
      |> render("login.json", %{token: token})
    else
      error -> handle_error(conn, error)
    end
  end
end
