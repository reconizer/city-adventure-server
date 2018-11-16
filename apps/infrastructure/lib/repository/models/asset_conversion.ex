defmodule Infrastructure.Repository.Models.AssetConversion do
  alias Infrastructure.Repository.Models
  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "asset_conversions" do
    field(:name, :string)
    field(:extension, :string)
    field(:type, :string)

    belongs_to(:asset, Models.Asset)
    timestamps()
  end

  def build(params) do
    changeset(%__MODULE__{}, params)
  end

  @fields ~w(id asset_id name type extension inserted_at updated_at)a
  @required_fields ~w(id asset_id name type extension inserted_at updated_at)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
