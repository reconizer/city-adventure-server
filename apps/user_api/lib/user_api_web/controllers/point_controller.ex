defmodule UserApiWeb.PointController do
  use UserApiWeb, :controller
  alias Domain.UserAdventure.Adventure, as: AdventureDomain
  alias Domain.UserAdventure.Repository.Adventure, as: AdventureRepository
  alias Domain.UserAdventure.Projections.Points, as: PointProjection
  alias UserApiWeb.PointContract

  def completed_points(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
         {:ok, validate_params} <-
           conn
           |> PointContract.list_of_completed_points(context),
         {:ok, points} <-
           validate_params
           |> PointProjection.get_completed_points() do
      session
      |> Session.update_context(%{"completed_points" => points})
    else
      %Session{valid?: false} ->
        session

      {:error, reason} ->
        session
        |> handle_errors(reason)
    end
    |> present(conn, UserApiWeb.PointView, "completed_points.json")
  end

  def resolve_position_point(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
         {:ok, validate_params} <-
           conn
           |> PointContract.resolve_point(context),
         {:ok, adventure} <-
           validate_params
           |> AdventureRepository.get(),
         {:ok, point} <-
           adventure
           |> AdventureDomain.check_point_position(validate_params),
         {:ok, _adventure} <-
           adventure
           |> AdventureDomain.check_adventure_completed(),
         {:ok, _adventure} <-
           adventure
           |> AdventureDomain.check_point_completed(point),
         {:ok, _} <- adventure |> AdventureDomain.check_answer_and_time(point) do
      adventure
      |> AdventureDomain.resolve_point(validate_params, point)
      |> case do
        {:ok, adventure} ->
          adventure
          |> AdventureRepository.save()

          session
          |> Session.update_context(%{"adventure" => adventure})
      end
    else
      %Session{valid?: false} ->
        session

      {:error, reason} ->
        session
        |> handle_errors(reason)
    end
    |> present(conn, UserApiWeb.PointView, "resolve_point_position.json")
  end
end
