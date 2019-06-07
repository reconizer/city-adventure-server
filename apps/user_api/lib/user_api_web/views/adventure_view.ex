defmodule UserApiWeb.AdventureView do
  use UserApiWeb, :view

  def render("index.json", %{session: %Session{context: %{"adventures" => adventures}} = _session}) do
    adventures
    |> Enum.map(&render_start_points/1)
  end

  def render("user_list.json", %{session: %Session{context: %{"adventures" => adventures}} = _session}) do
    adventures
    |> Enum.map(&render_user_adventure/1)
  end

  def render("show.json", %{session: %Session{context: %{"adventure" => adventure, "rankings" => rankings, "rating" => rating}} = _session}) do
    %{
      id: adventure.id,
      name: adventure.name,
      description: adventure.description,
      language: adventure.language,
      min_time: adventure.min_time,
      max_time: adventure.max_time,
      rating: rating.rating,
      rating_count: render_rating_count(rating.rating_count),
      author_id: adventure.creator.id,
      author_name: adventure.creator.name,
      author_image_url: asset_url(adventure.creator.asset),
      difficulty_level: adventure.difficulty_level,
      image_url: asset_url(adventure.asset),
      gallery: generate_gallery(adventure.images),
      top_five: rankings |> Enum.map(&render_ranking/1),
      current_user_ranking: render_ranking(adventure.user_ranking),
      current_user_rating: adventure.user_rating |> render_rating()
    }
  end

  def render("start.json", %{session: %Session{context: %{"start_point" => %{position: %{coordinates: {lng, lat}}} = start_point}} = _session}) do
    %{
      adventure_id: start_point.adventure_id,
      start_point_id: start_point.id,
      position: %{
        lat: lat,
        lng: lng
      },
      radius: start_point.radius
    }
  end

  def render("summary.json", %{session: %Session{context: %{"rankings" => rankings}} = _session}) do
    rankings
    |> Enum.take(10)
    |> Enum.map(fn r ->
      render_ranking(r)
    end)
  end

  def render("rating.json", %{session: %Session{context: %{"adventure" => %{user_rating: rating}}} = _session}) do
    %{
      user_id: rating.user_id,
      adventure_id: rating.adventure_id,
      rating: rating.rating
    }
  end

  defp generate_gallery([]), do: []

  defp generate_gallery(images) do
    images
    |> Enum.map(fn image ->
      asset_url(image.asset)
    end)
  end

  defp render_ranking(nil), do: nil

  defp render_ranking(owner_ranking) do
    %{
      completion_time: owner_ranking.completion_time,
      nick: owner_ranking.nick,
      position: owner_ranking.position,
      user_id: owner_ranking.user_id,
      avatar_url: asset_url(owner_ranking.asset)
    }
  end

  defp render_start_points(%{position: %{coordinates: {lng, lat}}} = adventure) do
    %{
      adventure_id: adventure.id,
      completed: adventure.completed,
      paid: adventure.paid,
      purchased: adventure.purchased,
      position: %{
        lat: lat,
        lng: lng
      },
      start_point_id: adventure.start_point_id,
      started: adventure.started
    }
  end

  defp render_user_adventure(adventure) do
    %{
      id: adventure.id,
      name: adventure.name,
      image_url: asset_url(adventure.asset),
      completion_time: adventure.user_ranking |> render_completion_time(),
      position: adventure.user_ranking |> render_position
    }
  end

  defp render_completion_time(nil), do: nil
  defp render_completion_time(user_ranking), do: user_ranking.completion_time

  defp render_position(nil), do: nil
  defp render_position(user_ranking), do: user_ranking.position

  defp render_rating_count(nil), do: 0
  defp render_rating_count(rating), do: rating

  defp render_rating(nil), do: nil
  defp render_rating(user_rating), do: user_rating.rating
end
