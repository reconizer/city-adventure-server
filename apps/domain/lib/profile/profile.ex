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

  def follow(profile, %{user_id: user_id, creator_id: creator_id} = params) do
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

  def unfollow(profile, %{user_id: user_id, creator_id: creator_id} = params) do
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
end
