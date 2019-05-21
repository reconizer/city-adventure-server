defmodule UserApiWeb.ProfileController do
  use UserApiWeb, :controller
  alias Domain.Profile.Repository.User, as: UserRepository
  alias Domain.Profile.Profile, as: ProfileDomain
  alias UserApiWeb.ProfileContract

  def show(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
         {:ok, validate_params} <-
           conn
           |> ProfileContract.show(context),
         {:ok, profile} <- validate_params |> UserRepository.get_by_id() do
      session
      |> Session.update_context(%{"profile" => profile})
    else
      %Session{valid?: false} = session ->
        session

      {:error, reason} ->
        session
        |> handle_errors(reason)
    end
    |> present(conn, UserApiWeb.ProfileView, "show.json")
  end

  def follow(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
         {:ok, validate_params} <-
           conn
           |> ProfileContract.follow_unfollow(context),
         {:ok, profile} <- validate_params |> UserRepository.get_by_id(),
         {:ok, creator_follower} <- profile |> ProfileDomain.follow(validate_params) do
      creator_follower
      |> UserRepository.save()
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
    with %Session{valid?: true} <- session,
         {:ok, validate_params} <-
           conn
           |> ProfileContract.follow_unfollow(context),
         {:ok, profile} <- validate_params |> UserRepository.get_by_id(),
         {:ok, creator_follower} <- profile |> ProfileDomain.unfollow(validate_params) do
      creator_follower
      |> UserRepository.save()
      |> handle_repository_action(conn)
    else
      %Session{valid?: false} = session ->
        session

      {:error, reason} ->
        session
        |> handle_errors(reason)
    end
  end
end
