defmodule Domain.Adventure.Adventure do
  alias Domain.Adventure.{
    Adventure,
    Point
  }
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:name, :string)
    field(:description, :string)
    field(:min_time, :integer)
    field(:max_time, :integer)
    field(:difficulty_level, :integer)
    field(:language, :string)
    embeds_many(:points, Point)
    embeds_many(:events, Domain.Event)
  end

  @fields []
  @required_fields @fields

  @spec changeset(Transfer.t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:points)
  end

end