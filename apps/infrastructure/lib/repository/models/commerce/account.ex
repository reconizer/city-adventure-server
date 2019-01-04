defmodule Infrastructure.Repository.Models.Commerce.Account do
  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset

  alias Infrastructure.Repository.Models.Commerce

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @schema_prefix "commerce"

  @fields ~w(id inserted_at updated_at)a
  @required_fields ~w()a

  schema "accounts" do
    has_one(:user_account, Commerce.UserAccount)
    has_one(:shop_account, Commerce.ShopAccount)
    has_one(:creator_account, Commerce.CreatorAccount)

    has_one(:user, through: [:user_account, :user])
    has_one(:shop, through: [:shop_account, :shop])
    has_one(:creator, through: [:creator_account, :creator])

    has_many(:outgoing_transfers, Commerce.Transfer, foreign_key: :from_account_id)
    has_many(:incoming_transfers, Commerce.Transfer, foreign_key: :to_account_id)

    timestamps()
  end

  def changeset(model, params) do
    model
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
