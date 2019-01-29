defmodule CreatorApiWeb.AdventureView do
  use CreatorApiWeb, :view

  def render("item.json", %{item: item}) do
    %{
      id: item.id,
      name: item.name,
      points:
        item.points
        |> Enum.map(fn point ->
          CreatorApiWeb.PointView.render("item.json", %{item: point})
        end),
      description: item.description,
      language: item.language,
      difficulty: item.difficulty_level,
      duration: %{
        min: item.min_time,
        max: item.max_time
      },
      shown: item.show,
      status: item.status
    }
  end

  def render("list.json", %{list: list}) do
    list
    |> Enum.map(&adventure_list_item/1)
  end

  def adventure_list_item(adventure) do
    %{
      id: adventure.id,
      name: adventure.name,
      shown: adventure.show,
      rating: adventure.rating,
      status: adventure.status,
      coverl_url: asset_url(adventure.asset)
    }
  end
end
