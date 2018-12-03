defmodule UserApiWeb.PointController do
  use UserApiWeb, :controller
  alias Domain.Adventure.Projections.Points, as: PointProjection
  alias Domain.Adventure.Repository.Point, as: PointRepository

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
    {:ok, :user_point_dont_exist} <- validate_params
                                     |> PointRepository.check_user_point(context["current_user"]),
    {:ok, user_point} <- validate_params
                         |> Map.put(:user_id, context["current_user"].id)
                         |> PointRepository.create_user_point(),
    {:ok, answers} <- point
                      |> PointRepository.get_answers()
    do
      answers
      |> case do
        nil ->
          point = user_point
          |> PointRepository.update_point_as_completed() 
          session
          |> Session.update_context(%{"completed_point" => point})
        result ->
          IO.inspect result 
          session
      end
     
    else
      %Session{valid?: false} ->
        session
      {:error, reason} ->
        session
        |> Session.add_error(reason)
    end
    |> present(conn, UserApiWeb.PointView, "resolve_point.json")
    end

end