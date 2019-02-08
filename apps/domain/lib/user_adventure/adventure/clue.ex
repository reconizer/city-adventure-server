defmodule Domain.UserAdventure.Adventure.Clue do
  alias Domain.UserAdventure.Adventure.{
    Clue,
    Asset
  }

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
    embeds_one(:asset, Asset)
  end

  @fields [:description, :tip, :type, :sort, :point_id, :asset_id, :id]
  @required_fields @fields

  @spec changeset(Clue.t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
