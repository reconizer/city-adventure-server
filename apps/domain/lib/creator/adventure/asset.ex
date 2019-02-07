defmodule Domain.Creator.Adventure.Asset do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}
  @type ok_t :: {:ok, t()}
  @type error :: {:error, any()}
  @type entity :: ok_t() | error()

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:type, :string)
    field(:name, :string)
    field(:extension, :string)
    embeds_many(:asset_conversions, Adventure.AssetConversion)
  end

  @fields ~w(id type name extension)a
  @required_fields @fields

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
