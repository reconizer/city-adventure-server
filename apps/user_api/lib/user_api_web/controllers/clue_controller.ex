defmodule UserApiWeb.ClueController do
  use UserApiWeb, :controller
  alias Domain.UserAdventure.Projections.Clues, as: CluesProjection
  alias Domain.UserAdventure.Projections.Points, as: PointsProjection
  alias UserApiWeb.ClueContract

  def index(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
      {:ok, validate_params} <- conn
                                |> ClueContract.index(context),
      {:ok, discovered_clues} <- validate_params
                                 |> PointsProjection.get_completed_points_with_clues()
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
      {:ok, validate_params} <- conn
                                |> ClueContract.list_for_points(context),
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