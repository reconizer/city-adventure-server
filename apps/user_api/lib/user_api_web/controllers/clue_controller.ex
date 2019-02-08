defmodule UserApiWeb.ClueController do
  use UserApiWeb, :controller
  alias Domain.UserAdventure.Repository.Adventure, as: AdventureRepository
  alias Domain.UserAdventure.Adventure, as: AdventureDomain
  alias Domain.UserAdventure.Projections.Clues, as: CluesProjection
  alias UserApiWeb.ClueContract

  def index(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
         {:ok, validate_params} <-
           conn
           |> ClueContract.index(context),
         {:ok, %{user_points: user_points} = adventure} <-
           validate_params
           |> AdventureRepository.get(),
         {:ok, points} <-
           adventure
           |> AdventureDomain.get_discovered_points() do
      session
      |> Session.update_context(%{"points" => points, "user_points" => user_points})
    else
      %Session{valid?: false} ->
        session

      {:error, reason} ->
        session
        |> handle_errors(reason)
    end
    |> present(conn, UserApiWeb.ClueView, "index.json")
  end

  def list_for_point(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
         {:ok, validate_params} <-
           conn
           |> ClueContract.list_for_points(context),
         {:ok, clues_for_point} <-
           validate_params
           |> CluesProjection.get_clues_for_point() do
      session
      |> Session.update_context(%{"clues" => clues_for_point})
    else
      %Session{valid?: false} ->
        session

      {:error, reason} ->
        session
        |> handle_errors(reason)
    end
    |> present(conn, UserApiWeb.ClueView, "list_for_point.json")
  end
end
