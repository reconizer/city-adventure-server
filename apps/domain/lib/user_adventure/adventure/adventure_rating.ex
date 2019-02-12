defmodule Domain.UserAdventure.Adventure.AdventureRating do
  alias Domain.UserAdventure.Adventure.{
    AdventureRating
  }

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field(:user_id, Ecto.UUID)
    field(:adventure_id, Ecto.UUID)
    field(:rating, :integer)
  end

  @fields [:user_id, :rating]
  @required_fields @fields

  @spec changeset(AdventureRating.t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
