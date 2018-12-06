defmodule Infrastructure.Repository.Models.Commerce.Transfer do
  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset

  alias Infrastructure.Repository.Models.Commerce

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @schema_prefix "commerce"

  @fields ~w(id from_account_id to_account_id transferable_id transferable_amount inserted_at updated_at)a
  @required_fields ~w(id from_account_id to_account_id transferable_id transferable_amount inserted_at updated_at)a

  schema "transfers" do
    belongs_to(:from_account, Commerce.Account)
    belongs_to(:to_account, Commerce.Account)
    belongs_to(:transferable, Commerce.Transferable)

    field(:transferable_amount, :integer)
    timestamps()
  end

  def changeset(model, params) do
    model
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
