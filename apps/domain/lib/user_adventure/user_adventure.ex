defmodule Domain.UserAdventure.UserAdventure do
  alias Domain.UserAdventure.{
    UserAdventure
  }
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field(:user_id, Ecto.UUID)
    field(:adventure_id, Ecto.UUID)
    field(:completed, :boolean)
  end

  @fields [:user_id, :point_id]
  @required_fields @fields

  @spec changeset(UserAdventure.t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end

end