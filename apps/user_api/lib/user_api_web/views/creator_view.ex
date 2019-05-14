defmodule UserApiWeb.CreatorView do
  use UserApiWeb, :view

  def render("show.json", %{session: %Session{context: %{"creator" => creator}} = _session}) do
    %{
      name: creator.name,
      description: creator.description,
      id: creator.id,
      image_url: asset_url(creator.asset)
    }
  end
end
