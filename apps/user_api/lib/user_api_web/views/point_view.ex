defmodule UserApiWeb.PointView do
  use UserApiWeb, :view

  def render("completed_points.json", %{session: %Session{context: %{"completed_points" => points}} = _session}) do
    points
    |> Enum.map(&render_points/1)
  end

  def render("resolve_point_position.json", %{session: %Session{context: %{"point" => %{coordinates: {lng, lat}} = point}} = _session}) do
    %{
      position: %{
        lat: lat,
        lng: lng
      },
      completed: point.completed,
      radius: point.radius,
      answer_type: nil
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