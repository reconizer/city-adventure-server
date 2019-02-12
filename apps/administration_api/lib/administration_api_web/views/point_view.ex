defmodule AdministrationApiWeb.PointView do
  use AdministrationApiWeb, :view

  def render("item.json", %{item: point}) do
    %{
      id: point.id,
      parent_id: point.parent_point_id,
      radius: point.radius,
      shown: point.show,
      position: %{
        lat: point.position.lat,
        lng: point.position.lng
      },
      clues:
        point.clues
        |> Enum.map(fn clue ->
          AdministrationApiWeb.ClueView.render("item.json", %{item: clue})
        end),
      time_answer: point.time_answer |> build_answer(:time),
      password_answer: point.password_answer |> build_answer(:password)
    }
  end

  def render("list.json", %{list: list}) do
    list
    |> Enum.map(fn point ->
      render("item.json", %{item: point})
    end)
  end

  def build_answer(nil, _), do: nil

  def build_answer(answer, :time) do
    %{start_time: answer.start_time, duration: answer.duration}
  end

  def build_answer(answer, :password) do
    %{type: answer.type, password: answer.password}
  end
end
