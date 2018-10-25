defmodule UserApiWeb.ClueView do
  use UserApiWeb, :view

  def render("index.json", %{session: %Session{context: %{"clues" => clues}} = _session}) do
    clues
    |> Enum.map(&render_clues/1)
  end

  defp render_clues(clue) do
    %{
      id: clue.id,
      type: clue.type,
      description: clue.description,
      point_id: clue.point_id,
      asset_url: asset_url(Path.join([clue.point_id, clue.type, clue.id]))   
    }
  end

end