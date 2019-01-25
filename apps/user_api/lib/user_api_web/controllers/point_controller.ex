defmodule UserApiWeb.PointController do
  use UserApiWeb, :controller
  alias Domain.UserAdventure.Adventure, as: AdventureDomain
  alias Domain.UserAdventure.Repository.Adventure, as: AdventureRepository
  alias Domain.UserAdventure.Projections.Points, as: PointProjection

  def completed_points(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
         {:ok, validate_params} <-
           context
           |> Contract.Adventure.CompletedPoints.validate(),
         {:ok, points} <-
           validate_params
           |> PointProjection.get_completed_points(context["current_user"]) do
      session
      |> Session.update_context(%{"completed_points" => points})
    else
      %Session{valid?: false} ->
        session

      {:error, reason} ->
        session
        |> Session.add_error(reason)
    end
    |> present(conn, UserApiWeb.PointView, "completed_points.json")
  end

  def resolve_position_point(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
         {:ok, validate_params} <-
           context
           |> Contract.Adventure.PointResolve.validate(),
         {:ok, adventure} <-
           validate_params
           |> AdventureRepository.get(context["current_user"]),
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
      |> AdventureDomain.resolve_point(validate_params, context["current_user"], point)
      |> case do
        {:error, result} ->
          session |> Session.add_error(result)

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
        |> Session.add_error(reason)
    end
    |> present(conn, UserApiWeb.PointView, "resolve_point_position.json")
  end
end
