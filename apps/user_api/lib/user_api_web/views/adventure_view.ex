defmodule UserApiWeb.AdventureView do
  use UserApiWeb, :view

  def render("index.json", %{session: %Session{context: %{"adventures" => adventures}} = _session}) do
    adventures
    |> Enum.map(&render_start_points/1)
  end

  def render("show.json", %{session: %Session{context: %{"adventure" => adventure}} = _session}) do
    %{
      id: adventure.id,
      name: adventure.name,
      description: adventure.description,
      language: adventure.language,
      min_time: adventure.min_time,
      max_time: adventure.max_time,
      rating: adventure.rating,
      rating_count: render_rating(adventure.rating_count),
      author_name: adventure.author_name,
      author_image_url: asset_url(adventure.author_asset),
      difficulty_level: adventure.difficulty_level,
      image_url: asset_url(adventure.asset),
      gallery: generate_gallery(adventure.images),
      top_five: adventure.top_five,
      current_user_ranking: adventure.owner_ranking,
      current_user_rating: adventure.owner_rating
    }
  end

  def render("start.json", %{session: %Session{context: %{"adventure" => %{start_point: %{position: %{coordinates: {lng, lat}}} = start_point}}} = _session}) do
    %{
      adventure_id: start_point.adventure_id,
      id: start_point.id,
      position: %{
        lat: lat,
        lng: lng
      },
      radius: start_point.radius
    }
  end

  def render("summary.json", %{session: %Session{context: %{"ranking" => ranking}} = _session}) do
    ranking
    |> Enum.map(fn r -> 
      %{
        user_id: r.user_id,
        position: r.position,
        nick: r.nick,
        completion_time: r.completion_time
      }
    end)
  end

  defp generate_gallery([]), do: []
  defp generate_gallery(images) do
    images
    |> Enum.map(fn image ->
      asset_url(image.asset)
    end)
  end

  defp render_owner_ranking(%{user_id: nil}), do: nil
  defp render_owner_ranking(owner_ranking) do
    %{
      completion_time: owner_ranking.completion_time,
      nick: owner_ranking.nick,
      position: owner_ranking.position,
      user_id: owner_ranking.user_id
    }
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

  defp render_rating(nil), do: 0
  defp render_rating(rating), do: rating

end
