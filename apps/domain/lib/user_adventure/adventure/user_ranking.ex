defmodule Domain.UserAdventure.Adventure.UserRanking do
  alias Domain.UserAdventure.Adventure.{
    UserRanking,
    Asset
  }

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field(:user_id, Ecto.UUID)
    field(:adventure_id, Ecto.UUID)
    field(:position, :integer)
    field(:nick, :string)
    field(:completion_time, :integer)
    embeds_one(:asset, Asset)
  end

  @fields [:user_id, :rating]
  @required_fields @fields

  @spec changeset(UserRanking.t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
