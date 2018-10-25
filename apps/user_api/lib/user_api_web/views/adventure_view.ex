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
      min_time: adventure.min_time,
      max_time: adventure.max_time,
      difficulty_level: adventure.difficulty_level,
      image_url: asset_url(adventure.id),
      gallery: generate_gallery(adventure.id, adventure.image_ids)
    }
  end

  defp generate_gallery(adventure_id, nil), do: []
  defp generate_gallery(adventure_id, image_ids) do
    image_ids
    |> Enum.map(fn image_id -> 
      asset_url(Path.join([adventure_id, image_id]))
    end)
  end

  defp render_start_points(%{position: %{coordinates: {lng, lat}}} = adventure) do
    %{
      adventure_id: adventure.adventure_id,
      completed: adventure.completed,
      paid: adventure.paid,
      position: %{
        lat: lat,
        lng: lng
      },
      start_point_id: adventure.start_point_id,
      started: adventure.started
    }
  end

end
