defmodule UserApiWeb.ClueController do
  use UserApiWeb, :controller
  alias Domain.UserAdventure.Projections.Clues, as: CluesProjection
  alias Domain.UserAdventure.Projections.Points, as: PointsProjection

  def index(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
      {:ok, validate_params} <- context
                                |> Contract.Adventure.ClueListing.validate(),
      {:ok, discovered_clues} <- validate_params
                                 |> PointsProjection.get_completed_points_with_clues(context["current_user"])
    do
      session
      |> Session.update_context(%{"clues" => discovered_clues})
    else
      %Session{valid?: false} ->
        session
      {:error, reason} ->
        session
        |> Session.add_error(reason)
    end
    |> present(conn, UserApiWeb.ClueView, "index.json")
  end

  def list_for_point(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
      {:ok, validate_params} <- context
                                |> Contract.Adventure.CluesForPoint.validate(),
      {:ok, clues_for_point} <- validate_params
                                |> CluesProjection.get_clues_for_point()
    do
      session
      |> Session.update_context(%{"clues" => clues_for_point})
    else
      %Session{valid?: false} ->
        session
      {:error, reason} ->
        session
        |> Session.add_error(reason)
    end
    |> present(conn, UserApiWeb.ClueView, "list_for_point.json")
  end

end