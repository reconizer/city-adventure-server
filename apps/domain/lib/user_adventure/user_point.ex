defmodule Domain.UserAdventure.UserPoint do
  alias Domain.UserAdventure.{
    UserPoint
  }
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field(:user_id, Ecto.UUID)
    field(:point_id, Ecto.UUID)
    field(:completed, :boolean)
    field(:position, Geo.PostGIS.Geometry)
  end

  @fields [:user_id, :point_id]
  @required_fields @fields

  @spec changeset(UserPoint.t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end

end