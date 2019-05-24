defmodule UserApiWeb.ProfileView do
  use UserApiWeb, :view

  def render("show.json", %{session: %Session{context: %{"profile" => profile}} = _session}) do
    %{
      nick: profile.nick,
      id: profile.id,
      email: profile.email,
      avatar_url: asset_url(profile.avatar.asset)
    }
  end

  def render("follow_unfollow.json", %{session: %Session{} = _session}) do
    %{}
  end
end
