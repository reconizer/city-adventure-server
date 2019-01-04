defmodule Infrastructure.Repository.Models.Commerce.Transferable do
  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset

  alias Infrastructure.Repository.Models.Commerce

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @schema_prefix "commerce"

  @fields ~w(id inserted_at updated_at)a
  @required_fields ~w(id inserted_at updated_at)a

  schema "transferables" do
    has_one(:transferable_adventure, Commerce.TransferableAdventure)
    has_one(:transferable_currency, Commerce.TransferableCurrency)
    has_one(:transferable_product, Commerce.TransferableProduct)

    has_one(:adventure, through: [:transferable_adventure, :adventure])
    has_one(:currency, through: [:transferable_adventure, :currency])
    has_one(:product, through: [:transferable_adventure, :product])
    timestamps()
  end

  def changeset(model, params) do
    model
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
