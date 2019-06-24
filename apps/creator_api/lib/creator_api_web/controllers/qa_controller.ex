defmodule CreatorApiWeb.QAController do
  use CreatorApiWeb, :controller

  alias CreatorApiWeb.QAContract
  alias Domain.AdventureReview
  alias Domain.AdventureReview.Message, as: ReviewMessage

  def list(conn, _params) do
    with {:ok, messages} <- AdventureReview.Repository.Message.all() do
      conn
      |> render("list.json", %{list: messages})
    else
      error -> handle_errors(conn, error)
    end
  end

  def create(conn, params) do
    with {:ok, validate_params} <- QAContract.create(conn, params),
         {:ok, message} <- validate_params |> ReviewMessage.new() do
      message
      |> AdventureReview.Repository.Message.save()
      |> handle_repository_action(conn)
    else
      {:error, error} ->
        conn
        |> handle_errors(error)
    end
  end
end
