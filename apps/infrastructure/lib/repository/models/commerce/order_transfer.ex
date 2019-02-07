defmodule Infrastructure.Repository.Models.Commerce.OrderTransfer do
  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset

  alias Infrastructure.Repository.Models.Commerce

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @schema_prefix "commerce"

  @fields ~w(id order_id transfer_id inserted_at updated_at)a
  @required_fields ~w(id order_id transfer_id inserted_at updated_at)a

  schema "order_transfers" do
    belongs_to(:order, Commerce.Order)
    belongs_to(:transfer, Commerce.Transfer)
    timestamps()
  end

  def changeset(model, params) do
    model
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
