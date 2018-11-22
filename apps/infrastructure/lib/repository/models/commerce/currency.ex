defmodule Infrastructure.Repository.Models.Commerce.Currency do
  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset

  alias Infrastructure.Repository.Models.Commerce

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @schema_prefix "commerce"

  @fields ~w(id name inserted_at updated_at)a
  @required_fields ~w(id name inserted_at updated_at)a

  schema "currencies" do
    field(:name, :string)
    timestamps()

    has_one(:transferable_currency, Commerce.TransferableCurrency)
    has_one(:transferable, through: :transferable_currency)
  end

  def changeset(model, params) do
    model
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
