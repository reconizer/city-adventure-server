defmodule UserApiWeb.PointController do
  use UserApiWeb, :controller
  alias Domain.Adventure.Projections.Points, as: PointProjection
  alias Domain.Adventure.Repository.Point, as: PointRepository
  alias Domain.Adventure.Repository.Answer, as: AnswerRepository
  alias Domain.Adventure.Service.ResolvePoint, as: ServiceResolvePoint

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
    {:ok, point} <- validate_params
                    |> PointRepository.check_point_position(),
    {:ok, answers} <- point
                      |> PointRepository.get_answers(),
    {:ok, true} <- answers |> AnswerRepository.check_answer_and_time(),
    {:ok, answer_type} <- answers |> AnswerRepository.find_answer_type()
    do
      validate_params
      |> ServiceResolvePoint.resolve_point(answers, context["current_user"])
      |> case do
        {:error, result} -> 
          session |> Session.add_error(result)
        {:ok, user_point} ->
          session
          |> Session.update_context(%{"point" => point, "user_point" => user_point, "answer_type" => answer_type})
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