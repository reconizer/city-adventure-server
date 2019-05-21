defmodule Domain.Profile.CreatorFollower do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field(:user_id, Ecto.UUID)
    field(:creator_id, Ecto.UUID)
  end

  @fields [:user_id, :creator_id]
  @required_fields @fields

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
