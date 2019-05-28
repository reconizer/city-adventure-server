defmodule Domain.Profile.Avatar do
  alias Domain.Profile.{
    Asset
  }

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field(:user_id, Ecto.UUID)
    field(:asset_id, Ecto.UUID)
    embeds_one(:asset, Asset)
  end

  @fields [:user_id, :asset_id]
  @required_fields @fields

  @spec changeset(Avatar.t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
