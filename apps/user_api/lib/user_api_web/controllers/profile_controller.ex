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
         {:ok, updated_profile} <- profile |> ProfileDomain.update_profile() do
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
end
