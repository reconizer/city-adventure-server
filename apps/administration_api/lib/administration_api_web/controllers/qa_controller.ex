defmodule AdministrationApiWeb.QAController do
  use AdministrationApiWeb, :controller

  alias AdministrationApiWeb.QAContract
  alias Domain.AdventureReview
  alias Domain.AdventureReview.Message, as: ReviewMessage
  alias Domain.Administration.User.Repository, as: AdministrationRepository

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
    with {:ok, %{administrator_id: administrator_id} = validate_params} <- QAContract.create(conn, params),
         %{email: email, id: id, name: name} <- administrator_id |> AdministrationRepository.get(),
         {:ok, message} <- validate_params |> Map.put(:author, %{email: email, id: id, type: "administrator", name: name}) |> ReviewMessage.new() do
      message
      |> IO.inspect()
      |> AdventureReview.Repository.Message.save()
      |> handle_repository_action(conn)
    else
      {:error, error} ->
        conn
        |> handle_error(error)
    end
  end
end
