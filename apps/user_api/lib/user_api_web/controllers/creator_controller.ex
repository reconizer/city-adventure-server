defmodule UserApiWeb.CreatorController do
  use UserApiWeb, :controller
  alias Domain.CreatorProfile.Repository.Creator, as: CreatorRepository
  alias Domain.CreatorProfile.Repository.Adventure, as: AdventureRepository
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

  def adventure_list(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
         {:ok, %{creator_id: creator_id, filter: filter}} <-
           conn
           |> CreatorContract.adventure_list(context),
         {:ok, adventures} <- creator_id |> AdventureRepository.get_by_creator_id(filter) do
      session
      |> Session.update_context(%{"adventure_list" => adventures})
    else
      %Session{valid?: false} = session ->
        session

      {:error, reason} ->
        session
        |> handle_errors(reason)
    end
    |> present(conn, UserApiWeb.CreatorView, "adventure_list.json")
  end
end
