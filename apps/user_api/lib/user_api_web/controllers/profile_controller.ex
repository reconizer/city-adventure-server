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

  def update(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
         {:ok, validate_params} <-
           conn
           |> ProfileContract.update(context),
         {:ok, profile} <- validate_params |> UserRepository.get_by_id(),
         {:ok, asset} <- validate_params |> UserRepository.get_asset(),
         {:ok, updated_profile} <- profile |> ProfileDomain.update_profile(validate_params, asset) do
      updated_profile
      |> UserRepository.save()

      session
      |> Session.update_context(%{"profile" => updated_profile})
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
         {:ok, :creator_follower_not_found} <- profile |> ProfileDomain.check_follower_creator(validate_params),
         {:ok, creator_follower} <- profile |> ProfileDomain.follow(validate_params) do
      creator_follower
      |> UserRepository.save()

      session
      |> Session.update_context(%{"profile" => creator_follower})
    else
      {:ok, :creator_follower_exists} ->
        session
        |> handle_errors({:creator_follower, "exist"})

      {:error, reason} ->
        session
        |> handle_errors(reason)
    end
    |> present(conn, UserApiWeb.ProfileView, "follow_unfollow.json")
  end

  def unfollow(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
         {:ok, validate_params} <-
           conn
           |> ProfileContract.follow_unfollow(context),
         {:ok, profile} <- validate_params |> UserRepository.get_by_id(),
         {:ok, :creator_follower_exists} <- profile |> ProfileDomain.check_follower_creator(validate_params),
         {:ok, creator_follower} <- profile |> ProfileDomain.unfollow(validate_params) do
      creator_follower
      |> UserRepository.save()

      session
      |> Session.update_context(%{"profile" => creator_follower})
    else
      %Session{valid?: false} = session ->
        session

      {:ok, :creator_follower_not_found} ->
        session
        |> handle_errors({:creator_follower, "not_found"})
    end
    |> present(conn, UserApiWeb.ProfileView, "follow_unfollow.json")
  end
end
