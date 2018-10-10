defmodule UserApiWeb.ClueView do
  use UserApiWeb, :view

  def render("index.json", %{session: %Session{context: %{"discovered_clues" => discovered_clues}} = session}) do
    discovered_clues
    |> Enum.map(&render_discovered_clues/1)
  end

  defp render_discovered_clues(clue) do
    %{
      id: clue.id,
      type: clue.type,
      description: clue.description,
      point_id: clue.point_id   
    }
  end

end