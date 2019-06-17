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

  def render("avatar_list.json", %{session: %Session{context: %{"avatar_list" => avatar_list}} = _session}) do
    avatar_list
    |> Enum.map(&render_avatar/1)
  end

  defp render_avatar(asset) do
    %{
      id: asset.id,
      url: asset_url(asset)
    }
  end
end
