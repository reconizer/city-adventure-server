defmodule AdministrationApiWeb.QAController do
  use AdministrationApiWeb, :controller

  alias AdministrationApiWeb.QAContract
  alias Domain.AdventureReview
  alias Domain.AdventureReview.Message, as: ReviewMessage

  @doc """
  path: /api/points
  method: GET
  """
  def list(conn, params) do
    filters = %{
      "filters" => %{"timestamp" => params |> Map.get("timestamp", nil)},
      "page" => params |> Map.get("page", "1")
    }

    params =
      params
      |> Map.put("filter", filters)

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
    with {:ok, validate_params} <- QAContract.create(conn, params),
         {:ok, message} <- validate_params |> ReviewMessage.new() do
      message
      |> AdventureReview.Repository.Message.save()
      |> handle_repository_action(conn)
    else
      {:error, error} ->
        conn
        |> handle_error(error)
    end
  end
end
