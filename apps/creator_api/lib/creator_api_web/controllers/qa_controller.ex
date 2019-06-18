defmodule CreatorApiWeb.QAController do
  use CreatorApiWeb, :controller

  alias CreatorApiWeb.QAContract
  alias Domain.AdventureReview
  alias Domain.AdventureReview.Message, as: ReviewMessage
  alias Domain.Creator.Repository.User, as: CreatorRepository

  def list(conn, params) do
    with {:ok, params} <- QAContract.list(conn, params),
         {:ok, messages} <- AdventureReview.Repository.Message.all(params.filter) do
      conn
      |> render("list.json", %{list: messages})
    else
      error -> handle_errors(conn, error)
    end
  end

  def create(conn, params) do
    with {:ok, %{creator_id: creator_id} = validate_params} <- QAContract.create(conn, params),
         %{email: email, id: id, name: name} <- creator_id |> CreatorRepository.get!(),
         {:ok, message} <- validate_params |> Map.put(:author, %{email: email, id: id, type: "creator", name: name}) |> ReviewMessage.new() do
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
