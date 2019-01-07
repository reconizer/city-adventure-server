defmodule Infrastructure.Repository.Models.Commerce.ShopAccount do
  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset

  alias Infrastructure.Repository.Models.Commerce

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @schema_prefix "commerce"

  @fields ~w(id shop_id account_id inserted_at updated_at)a
  @required_fields ~w(id shop_id account_id inserted_at updated_at)a

  schema "shop_accounts" do
    belongs_to(:shop, Commerce.Shop)
    belongs_to(:account, Commerce.Account)
    timestamps()
  end

  def changeset(model, params) do
    model
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
