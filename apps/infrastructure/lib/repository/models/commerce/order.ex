defmodule Infrastructure.Repository.Models.Commerce.Order do
  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset

  alias Infrastructure.Repository.Models.Commerce

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @schema_prefix "commerce"

  @fields ~w(id inserted_at updated_at)a
  @required_fields ~w()a

  schema "orders" do
    has_many(:order_transfers, Commerce.OrderTransfer)
    has_many(:transfers, through: [:order_transfers, :transfer])

    timestamps()
  end

  def changeset(model, params) do
    model
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
