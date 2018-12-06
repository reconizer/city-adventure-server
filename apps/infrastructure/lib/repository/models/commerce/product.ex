defmodule Infrastructure.Repository.Models.Commerce.Product do
  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset

  alias Infrastructure.Repository.Models.Commerce

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @schema_prefix "commerce"

  @fields ~w(id name google_product_id apple_product_id inserted_at updated_at)a
  @required_fields ~w(id name inserted_at updated_at)a

  schema "products" do
    field(:name, :string)
    field(:google_product_id)
    field(:apple_product_id)

    has_one(:transferable_product, Commerce.TransferableProduct)
    has_one(:transferable, through: [:transferable_product, :transferable])

    timestamps()
  end

  def changeset(model, params) do
    model
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
