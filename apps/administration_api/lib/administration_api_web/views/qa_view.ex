defmodule AdministrationApiWeb.QAView do
  use AdministrationApiWeb, :view

  def render("list.json", %{list: list}) do
    list
    |> Enum.map(fn item ->
      %{
        content: item.content,
        created_at: item.created_at,
        name: item.author.name,
        type: item.author.type
      }
    end)
  end
end
