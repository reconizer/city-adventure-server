defmodule UserApiWeb.PointView do
  use UserApiWeb, :view

  def render("completed_points.json", %{session: %Session{context: %{"completed_points" => points}} = _session}) do
    points
    |> Enum.map(&render_points/1)
  end

  def render("resolve_point_position.json", %{session: %Session{context: %{"adventure" => %{points: points, user_points: user_points} = adventure}} = _session}) do
    %{
      position: points |> find_point(adventure.current_point_id) |> render_position(),
      completed: user_points |> find_user_point(adventure.current_point_id) |> Map.get(:completed),
      radius: points |> find_point(adventure.current_point_id) |> Map.get(:radius),
      answer_type:  points |> find_point(adventure.current_point_id) |> Map.get(:answer_type),
      last_point: points |> find_point(adventure.current_point_id) |> Map.get(:last_point)
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

  defp find_user_point(user_points, current_point_id) do
    user_points
    |> Enum.find(fn user_point -> 
      user_point.point_id == current_point_id
    end)
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