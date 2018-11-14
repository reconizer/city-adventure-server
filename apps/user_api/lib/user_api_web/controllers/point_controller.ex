defmodule UserApiWeb.PointController do
  use UserApiWeb, :controller
  alias Domain.Adventure.Projections.Points, as: PointProjection

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

end