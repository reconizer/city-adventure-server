defmodule CreatorApiWeb.ClueView do
  use CreatorApiWeb, :view

  def render("item.json", %{item: clue}) do
    %{
      id: clue.id,
      type: clue.type,
      point_id: clue.poinr_id,
      description: clue.description,
      order: clue.sort,
      tip: clue.tip,
      url: clue.url
    }
  end
end
