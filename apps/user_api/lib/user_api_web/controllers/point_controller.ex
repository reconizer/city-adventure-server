defmodule UserApiWeb.PointController do
  use UserApiWeb, :controller
  alias Domain.Adventure.Projections.Points, as: PointProjection
  alias Domain.Adventure.Repository.Point, as: PointRepository
  alias Domain.Adventure.Repository.Answer, as: AnswerRepository

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
                              |> Contract.Adventure.PointPosition.validate(),
    {:ok, point} <- validate_params
                    |> PointRepository.check_point_position(),
    {:ok, answers} <- point
                      |> PointRepository.get_answers(),
    {:ok} <- answers |> AnswerRepository.check_answer_and_time(),
    {:ok, :user_point_dont_exist} <- validate_params
                                     |> PointRepository.check_user_point(context["current_user"])
    do
      answers
      |> case do
        nil ->
          user_point = validate_params
          |> Map.put(:user_id, context["current_user"].id)
          |> Map.put(:completed, true)
          |> PointRepository.create_user_point()
          session
          |> Session.update_context(%{"user_point" => user_point, "point" => point})
        result ->
          user_point = validate_params
          |> Map.put(:user_id, context["current_user"].id)
          |> PointRepository.create_user_point()
          session
          |> Session.update_context(%{"user_point" => user_point, "point" => point})
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