defmodule UserApiWeb.CreatorController do
  use UserApiWeb, :controller
  alias Domain.CreatorProfile.Repository.Creator, as: CreatorRepository
  alias Domain.CreatorProfile.Repository.Adventure, as: AdventureRepository
  alias Domain.Profile.CreatorProfile, as: CreatorProfileDomain
  alias UserApiWeb.CreatorContract
  alias Domain.Profile.Repository.CreatorFollower, as: CreatorFollowerRepository

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

  def follow(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
         {:ok, validate_params} <-
           conn
           |> CreatorContract.follow_unfollow(context),
         {:ok, creator_follower} <- validate_params |> CreatorProfileDomain.follow() do
      creator_follower
      |> CreatorFollowerRepository.save()
      |> handle_repository_action(conn)
    else
      %Session{valid?: false} = session ->
        session

      {:error, reason} ->
        session
        |> handle_errors(reason)
    end
  end

  def unfollow(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
  end
end
