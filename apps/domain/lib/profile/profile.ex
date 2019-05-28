defmodule Domain.Profile.Profile do
  @moduledoc """
  Domain for profile management
  """

  use Ecto.Schema
  use Domain.Event, "Profile"
  import Ecto.Changeset

  alias Domain.Profile.{
    Avatar,
    CreatorFollower
  }

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:nick, :string)
    field(:email, :string)
    embeds_one(:avatar, Avatar)
    embeds_many(:creator_followers, CreatorFollower)

    aggregate_fields()
  end

  @fields ~w(nick)a

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
  end

  def update_profile(profile, params, new_asset) do
    profile
    |> update_nick(params)
    |> update_avatar(new_asset)
  end

  def update_nick(profile, params) do
    profile
    |> changeset(params)
    |> case do
      %{valid?: true} = changeset ->
        changeset
        |> apply_changes
        |> emit("NickChanged", changeset.changes)

      changeset ->
        {:error, changeset}
    end
  end

  defp update_avatar({:ok, %{avatar: avatar} = profile}, %{id: _asset_id} = asset) do
    profile.avatar
    |> Avatar.changeset(%{
      asset_id: asset.id
    })
    |> case do
      %{valid?: true} ->
        profile
        |> do_change_avatar(asset)
        |> emit("AvatarChanged", %{
          user_id: avatar.user_id,
          asset_id: asset.id
        })

      changeset ->
        {:error, changeset}
    end
  end

  defp update_avatar({:ok, _profile} = result, nil) do
    result
  end

  defp update_avatar({:error, _} = error, _) do
    error
  end

  def check_follower_creator(profile, %{user_id: user_id, creator_id: creator_id}) do
    profile
    |> Map.get(:creator_followers)
    |> Enum.find(fn creator_follower ->
      creator_follower.user_id == user_id and creator_follower.creator_id == creator_id
    end)
    |> case do
      nil -> {:ok, :creator_follower_not_found}
      _result -> {:ok, :creator_follower_exists}
    end
  end

  def follow(profile, params) do
    %CreatorFollower{}
    |> CreatorFollower.changeset(params)
    |> case do
      %{valid?: true} = changeset ->
        {:ok, changeset |> apply_changes}

      changeset ->
        {:error, changeset}
    end
    |> case do
      {:error, _} = error ->
        error

      {:ok, creator_follower} ->
        new_creator_follower = profile.creator_followers ++ [creator_follower]

        profile = %{profile | creator_followers: new_creator_follower}

        profile
        |> emit("FollowCreator", %{
          user_id: creator_follower.user_id,
          creator_id: creator_follower.creator_id
        })
    end
  end

  def unfollow(profile, params) do
    %CreatorFollower{}
    |> CreatorFollower.changeset(params)
    |> case do
      %{valid?: true} = changeset ->
        {:ok, changeset |> apply_changes}

      changeset ->
        {:error, changeset}
    end
    |> case do
      {:error, _} = error ->
        error

      {:ok, creator_follower} ->
        profile
        |> filter_creator_follower(params)
        |> emit("UnfollowCreator", %{
          user_id: creator_follower.user_id,
          creator_id: creator_follower.creator_id
        })
    end
  end

  defp filter_creator_follower(profile, %{user_id: user_id, creator_id: creator_id}) do
    creator_followers =
      profile
      |> Map.get(:creator_followers)
      |> Enum.reject(fn creator_follower ->
        creator_follower.user_id == user_id and creator_follower.creator_id == creator_id
      end)

    %{profile | creator_followers: creator_followers}
  end

  defp do_change_avatar(profile, new_asset) do
    avatar =
      profile
      |> Map.get(:avatar)
      |> Map.put(:asset_id, new_asset.id)
      |> Map.put(:asset, new_asset)

    profile
    |> Map.put(:avatar, avatar)
  end
end
