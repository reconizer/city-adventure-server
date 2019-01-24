defmodule CreatorApiWeb.PointView do
  use CreatorApiWeb, :view

  def render("item.json", %{item: point}) do
    %{
      id: point.id,
      parent_point_id: point.parent_point_id,
      radius: point.radius,
      show: point.show,
      answers: point.answers,
      position: %{
        lat: point.position.lat,
        lng: point.position.lng
      },
      clues:
        point.clues
        |> Enum.map(fn clue ->
          CreatorApiWeb.ClueView.render("item.json", %{item: clue})
        end)
    }
  end
end
