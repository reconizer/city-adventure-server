defmodule UserApiWeb.AdventureView do
  use UserApiWeb, :view

  def render("index.json", session) do
    %{}
  end

  def render("show.json", %{session: %Session{context: %{"adventure" => adventure}} = session}) do
    %{
      name: adventure.name,
      description: adventure.description,
      language: adventure.language,
      estimated_time: adventure.estimated_time,
      difficulty_level: adventure.difficulty_level
    }
  end

end
