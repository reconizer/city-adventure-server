defmodule UserApiWeb.AdventureView do
  use UserApiWeb, :view

  def render("index.json", %{session: %Session{context: %{"adventures" => adventures}} = _session}) do
    adventures
    |> Enum.map(&render_start_points/1)
  end

  def render("show.json", %{session: %Session{context: %{"adventure" => adventure}} = _session}) do
    %{
      name: adventure.name,
      description: adventure.description,
      language: adventure.language,
      estimated_time: adventure.estimated_time,
      difficulty_level: adventure.difficulty_level
    }
  end

  defp render_start_points(%{position: %{coordinates: {lng, lat}}} = adventure) do
    %{
      adventure_id: adventure.adventure_id,
      completed: adventure.completed,
      position: %{
        lat: lat,
        lng: lng
      },
      start_point_id: adventure.start_point_id,
      started: adventure.started
    }
  end

end
