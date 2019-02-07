defmodule AdministrationApiWeb.Creator.AdventureController do
  use AdministrationApiWeb, :controller

  alias AdministrationApiWeb.Creator.AdventureContract
  alias Domain.Administration

  def list(conn, params) do
    with {:ok, params} <- AdventureContract.list(conn, params) do
      conn
      |> put_resp_content_type("application/json")
      |> resp(200, Poison.encode!(%{}))
    else
      error ->
        conn
        |> handle_error(error)
    end
  end

  def item(conn, params) do
    with {:ok, params} <- AdventureContract.item(conn, params) do
      conn
      |> put_resp_content_type("application/json")
      |> resp(200, Poison.encode!(%{}))
    else
      error ->
        conn
        |> handle_error(error)
    end
  end
end
