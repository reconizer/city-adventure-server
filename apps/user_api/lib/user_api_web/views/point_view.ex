defmodule UserApiWeb.PointView do
  use UserApiWeb, :view

  def render("completed_points.json", %{session: %Session{context: %{"completed_points" => points}} = _session}) do
    points
    |> Enum.map(&render_points/1)
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