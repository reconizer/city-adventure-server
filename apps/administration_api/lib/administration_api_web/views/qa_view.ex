defmodule AdministrationApiWeb.QAView do
  use AdministrationApiWeb, :view

  def render("list.json", %{list: list}) do
    list
    |> Enum.map(fn item ->
      item
      |> render_message()
    end)
  end

  defp render_message(%{author: author} = item) when is_map(author) do
    %{
      id: item.id,
      content: item.content,
      created_at: item.created_at |> Timex.to_unix(),
      name: author.name,
      type: author.type
    }
  end

  defp render_message(%{author: author} = item) do
    %{
      id: item.id,
      content: item.content,
      created_at: item.created_at |> Timex.to_unix(),
      name: "Event",
      type: author
    }
  end
end
