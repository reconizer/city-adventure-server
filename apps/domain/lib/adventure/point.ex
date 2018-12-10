defmodule Domain.Adventure.Point do
  alias Domain.Adventure.{
    Point,
    Clue
  }
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:position, Geo.PostGIS.Geometry)
    field(:show, :boolean)
    field(:radius, :integer)
    field(:parent_point_id, Ecto.UUID)
    field(:adventure_id, Ecto.UUID)
    embeds_many(:clues, Clue)
  end

  @fields [:position, :show, :radius, :parent_point_id, :adventure_id]
  @required_fields @fields

  @spec changeset(Point.t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:clues)
  end

end