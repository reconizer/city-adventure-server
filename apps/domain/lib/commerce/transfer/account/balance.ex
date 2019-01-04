defmodule Domain.Commerce.Transfer.Account.Balance do
  alias Domain.Commerce.Transfer.Account
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field(:transferable_id, :binary_id)
    field(:amount, :integer)
  end

  @fields [:transferable_id, :amount]
  @required_fields @fields

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
