defmodule Domain.Creator.Adventure.Image do
  use Ecto.Schema
  import Ecto.Changeset

  alias Domain.Creator.Adventure

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:sort, :integer)
    field(:adventure_id, :binary_id)
    embeds_one(:asset, Adventure.Asset)
  end

  @fields ~w(sort adventure_id)a
  @required_fields @fields

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
