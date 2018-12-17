defmodule UserApiWeb.PointController do
  use UserApiWeb, :controller
  alias Domain.UserAdventure.Adventure, as: AdventureDomain
  alias Domain.Adventure.Projections.Points, as: PointProjection
  alias Domain.UserAdventure.Repository.Point, as: PointRepository
  alias Domain.UserAdventure.Repository.Answer, as: AnswerRepository
  alias Domain.UserAdventure.Service.ResolvePoint, as: ServiceResolvePoint

  def completed_points(%{assigns: %{session: %Session{context: context} = session}} = conn, _) do
    with %Session{valid?: true} <- session,
      {:ok, validate_params} <- context
                                |> Contract.Adventure.CompletedPoints.validate(),
      {:ok, points} <- validate_params
                       |> PointProjection.get_completed_points(context["current_user"])
    do
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
    {:ok, validate_params} <- context
                              |> Contract.Adventure.PointResolve.validate(),
    {:ok, adventure} <- validate_params
                        |> ServiceResolvePoint.get_adventure(),
    {:ok, _point} <- adventure
                     |> AdventureDomain.check_point_position(validate_params),
    {:ok, _} <- adventure
                |> AdventureDomain.check_answer_and_time(validate_params)
    do
      adventure
      |> ServiceResolvePoint.resolve_point(validate_params)
      |> case do
        {:error, result} -> 
          session |> Session.add_error(result)
        {:ok, adventure} ->
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