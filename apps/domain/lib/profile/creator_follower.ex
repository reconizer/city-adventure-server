defmodule Domain.Profile.CreatorProfile do
  use Ecto.Schema
  import Ecto.Changeset

  alias Domain.Profile.CreatorProfile
  use Domain.Event, "Profile.CreatorFollower"

  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field(:user_id, Ecto.UUID)
    field(:creator_id, Ecto.UUID)
  end

  @fields [:user_id, :creator_id]
  @required_fields @fields

  @spec changeset(Avatar.t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end

  def follow(${user_id: user_id, creator_id: creator_id}) do
    %CreatorProfile{
      user_id: user_id,
      creator_id: creator_id
    }
    |> changeset(params)
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
        user
        |> emit("Follow", %{
          user_id: creator_follower.user_id,
          creator_id: creator_follower.creator_id
        })
    end
  end

  def unfollow(${user_id: user_id, creator_id: creator_id}) do
    %CreatorProfile{
      user_id: user_id,
      creator_id: creator_id
    }
    |> changeset(params)
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
        user
        |> emit("Unfollow", %{
          user_id: creator_follower.user_id,
          creator_id: creator_follower.creator_id
        })
    end
  end
end
