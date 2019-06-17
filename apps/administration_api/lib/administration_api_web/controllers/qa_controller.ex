defmodule AdministrationApiWeb.QAController do
  use AdministrationApiWeb, :controller

  alias AdministrationApiWeb.QAContract
  alias Domain.AdventureReview

  @doc """
  path: /api/points
  method: GET
  """
  def list(conn, params) do
    with {:ok, params} <- QAContract.list(conn, params),
         {:ok, messages} <- AdventureReview.Repository.Message.all(params.filter) do
      conn
      |> render("list.json", %{list: messages})
    else
      error -> handle_error(conn, error)
    end
  end

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, params) do
    QAContract.create(conn, params)
    |> case do
      {:ok, _params} ->
        conn
        |> resp(200, "OK")

      error ->
        conn
        |> handle_error(error)
    end
  end
end
