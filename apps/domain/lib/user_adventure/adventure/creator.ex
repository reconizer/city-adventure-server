defmodule Domain.UserAdventure.Adventure.Creator do
  alias Domain.UserAdventure.Adventure.{
    Creator
  }

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:name, :string)
    embeds_one(:asset, Asset)
  end

  @fields [:name, :id]
  @required_fields @fields

  @spec changeset(Creator.t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
