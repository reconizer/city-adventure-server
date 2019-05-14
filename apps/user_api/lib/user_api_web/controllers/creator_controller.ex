defmodule UserApiWeb.CreatorController do
  use UserApiWeb, :controller
  alias Domain.CreatorProfile.Repository.Creator, as: CreatorRepository
  alias UserApiWeb.CreatorContract

  def show(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
         {:ok, %{creator_id: creator_id}} <-
           conn
           |> CreatorContract.show(context),
         {:ok, creator} <- creator_id |> CreatorRepository.get() do
      session
      |> Session.update_context(%{"creator" => creator})
    else
      %Session{valid?: false} = session ->
        session

      {:error, reason} ->
        session
        |> handle_errors(reason)
    end
    |> present(conn, UserApiWeb.CreatorView, "show.json")
  end
end
