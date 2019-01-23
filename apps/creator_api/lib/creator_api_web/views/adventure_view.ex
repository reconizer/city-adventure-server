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
      name: item.name,
      description: item.description,
      language: item.language,
      difficulty_level: item.difficulty_level,
      min_time: item.min_time,
      max_time: item.max_time,
      show: item.show
    }
  end

  def render("list.json", %{list: list}) do
    list
  end
end
