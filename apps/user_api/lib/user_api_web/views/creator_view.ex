defmodule UserApiWeb.CreatorView do
  use UserApiWeb, :view

  def render("show.json", %{session: %Session{context: %{"creator" => creator}} = _session}) do
    %{
      name: creator.name,
      description: creator.description,
      id: creator.id,
      followers_count: creator.followers_count,
      image_url: asset_url(creator.asset)
    }
  end

  def render("adventure_list.json", %{session: %Session{context: %{"adventure_list" => adventures}} = _session}) do
    adventures
    |> Enum.map(&render_adventure/1)
  end

  defp render_adventure(adventure) do
    %{
      image_url: asset_url(adventure.asset),
      difficulty_level: adventure.difficulty_level,
      id: adventure.id,
      max_time: adventure.max_time,
      min_time: adventure.min_time,
      rating: adventure.rating
    }
  end
end
