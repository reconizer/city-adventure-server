defmodule UserApiWeb.PointView do
  use UserApiWeb, :view

  def render("completed_points.json", %{session: %Session{context: %{"user_points" => user_points, "completed_points" => points}} = _session}) do
    points
    |> Enum.map(fn point ->
      point
      |> render_points(user_points)
    end)
  end

  def render("resolve_point_position.json", %{session: %Session{context: %{"adventure" => %{points: points, user_points: user_points} = adventure}} = _session}) do
    %{
      position: points |> find_point(adventure.current_point_id) |> render_position(),
      completed: user_points |> find_user_point(adventure.current_point_id) |> Map.get(:completed),
      radius: points |> find_point(adventure.current_point_id) |> Map.get(:radius),
      answer_type: points |> find_point(adventure.current_point_id) |> Map.get(:answer_type),
      last_point: points |> find_point(adventure.current_point_id) |> Map.get(:last_point),
      current_point_id: adventure.current_point_id
    }
  end

  defp render_points(%{position: %{coordinates: {lng, lat}}} = point, user_points) do
    %{
      position: %{
        lat: lat,
        lng: lng
      },
      id: point.id,
      completed: user_points |> check_completed_point(point.id),
      radius: point.radius
    }
  end

  defp find_user_point(user_points, current_point_id) do
    user_points
    |> Enum.find(fn user_point ->
      user_point.point_id == current_point_id
    end)
  end

  defp check_completed_point(user_points, point_id) do
    user_points
    |> find_user_point(point_id)
    |> Map.get(:completed)
  end

  defp find_point(points, current_point_id) do
    points
    |> Enum.find(fn point ->
      point.id == current_point_id
    end)
  end

  defp render_position(%{position: %{coordinates: {lng, lat}}}) do
    %{
      lat: lat,
      lng: lng
    }
  end
end
