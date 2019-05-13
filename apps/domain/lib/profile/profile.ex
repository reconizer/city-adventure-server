defmodule Domain.Profile.Profile do
  @moduledoc """
  Domain for profile management
  """

  use Ecto.Schema
  use Domain.Event, "Profile"
  import Ecto.Changeset

  alias Domain.Profile.{
    Avatar,
    Porofile
  }

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:nick, :string)
    field(:email, :string)
    embeds_one(:avatar, Avatar)

    aggregate_fields()
  end

  @fields ~w(id nick)a
  @required_fields ~w(id nick)a

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> cast_embed(:points)
  end

  defp update_profile(profile, %{nick: nick}, new_asset) do
    profile
    |> update_avatar(new_asset)
  end

  defp update_avatar(%{avatar: avatar} = profile, %{id: asset_id} = new_asset) do
    profile
    |> do_change_avatar(new_asset)
    |> emit("AvatarChanged", %{
      user_id: avatar.user_id,
      asset_id: asset_id
    })
  end
end
