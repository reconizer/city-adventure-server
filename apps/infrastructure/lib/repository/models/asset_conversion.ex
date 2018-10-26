defmodule Infrastructure.Repository.Models.AssetConversion do
  alias Infrastructure.Repository.Models
  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "asset_conversions" do
    field(:sent, :boolean, default: false)
    field(:finished, :boolean, default: false)

    field(:name, :string)

    belongs_to(:asset, Models.Asset)
    timestamps()
  end

  def build(params) do
    changeset(%__MODULE__{}, params)
  end

  @fields ~w(id asset_id sent finished name inserted_at updated_at)a
  @required_fields ~w(id asset_id sent finished name inserted_at updated_at)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end

  def pending_conversions(opts \\ []) do
    import Ecto.Query
    limit = opts |> Keyword.get(:limit, 10)

    Models.AssetConversion
    |> where([asset_conversion], asset_conversion.sent == false)
    |> order_by([asset_conversion], desc: asset_conversion.updated_at)
    |> limit(^limit)
    |> Infrastructure.Repository.all()
  end
end
