defmodule Domain.Adventure.Clue do
  alias Domain.Adventure.Clue
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:description, :string)
    field(:type, :string)
    field(:tip, :boolean)
    field(:sort, :integer)
    field(:point_id, Ecto.UUID)
    field(:asset_id, Ecto.UUID)
  end

  @fields [:description, :tip, :type, :sort, :point_id, :asset_id]
  @required_fields @fields

  @spec changeset(Clue.t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end

end