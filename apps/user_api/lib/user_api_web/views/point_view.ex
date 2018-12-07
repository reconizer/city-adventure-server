defmodule UserApiWeb.PointView do
  use UserApiWeb, :view

  def render("completed_points.json", %{session: %Session{context: %{"completed_points" => points}} = _session}) do
    points
    |> Enum.map(&render_points/1)
  end

  def render("resolve_point_position.json", %{session: %Session{context: %{"point" => %{position: %{coordinates: {lng, lat}}} = point, "user_point" => user_point, "answer_type" => type}} = _session}) do
    %{
      position: %{
        lat: lat,
        lng: lng
      },
      completed: user_point.completed,
      radius: point.radius,
      answer_type: type
    }
  end

  defp render_points(%{position: %{coordinates: {lng, lat}}} = point) do
    %{
      position: %{
        lat: lat,
        lng: lng
      },
      id: point.id,
      completed: point.completed
    }
  end

end