defmodule CreatorApiWeb.QAController do
  use CreatorApiWeb, :controller

  alias CreatorApiWeb.QAContract

  def list(conn, params) do
    QAContract.list(conn, params)
    |> case do
      {:ok, _params} ->
        conn
        |> resp(200, "OK")

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def create(conn, params) do
    QAContract.create(conn, params)
    |> case do
      {:ok, _params} ->
        conn
        |> resp(200, "OK")

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end
end
