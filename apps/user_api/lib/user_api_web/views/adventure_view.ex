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
      rating_count: adventure.rating_count,
      author_name: adventure.author_name,
      author_image_url: asset_url(Path.join([adventure.author_id])),
      difficulty_level: adventure.difficulty_level,
      image_url: asset_url(adventure.id),
      gallery: generate_gallery(adventure.id, adventure.image_ids),
      top_five: render_ranking(adventure.top_five),
      owner_ranking: render_owner_ranking(adventure.owner_ranking)
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

  defp generate_gallery(_adventure_id, nil), do: []
  defp generate_gallery(adventure_id, image_ids) do
    image_ids
    |> Enum.map(fn image_id -> 
      asset_url(Path.join([adventure_id, image_id]))
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

  defp render_ranking(nil), do: []
  defp render_ranking(ranking) do
    ranking
    |> Enum.map(fn {user_id, position, completion_time, nick} -> 
      %{
        user_id: user_id,
        position: position,
        nick: nick,
        completion_time: completion_time
      }
    end)
  end

end
