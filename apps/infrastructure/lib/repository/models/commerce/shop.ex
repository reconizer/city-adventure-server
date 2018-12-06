defmodule Infrastructure.Repository.Models.Commerce.Shop do
  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset

  alias Infrastructure.Repository.Models.Commerce

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @schema_prefix "commerce"

  @fields ~w(id type inserted_at updated_at)a
  @required_fields ~w(id type inserted_at updated_at)a

  schema "shops" do
    field(:type, :string)

    has_one(:shop_account, Commerce.ShopAccount)
    has_one(:account, through: [:shop_account, :account])
    timestamps()
  end

  def changeset(model, params) do
    model
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
