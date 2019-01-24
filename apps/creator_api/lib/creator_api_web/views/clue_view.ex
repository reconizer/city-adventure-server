defmodule CreatorApiWeb.ClueView do
  use CreatorApiWeb, :view

  def render("item.json", %{item: clue}) do
    %{
      id: clue.id,
      type: clue.type,
      description: clue.description,
      sort: clue.sort,
      tip: clue.tip,
      asset_id: clue.asset_id
    }
  end
end
