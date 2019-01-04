defmodule Domain.Commerce.Transfer.Transaction do
  alias Domain.Commerce.Transfer
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:from_account_id, :binary_id)
    field(:to_account_id, :binary_id)
    field(:transferable_id, :binary_id)
    field(:transferable_amount, :integer)
    field(:created_at, :naive_datetime)
  end

  @fields [:id, :from_account_id, :to_account_id, :transferable_id, :transferable_amount, :created_at]
  @required_fields @fields

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
