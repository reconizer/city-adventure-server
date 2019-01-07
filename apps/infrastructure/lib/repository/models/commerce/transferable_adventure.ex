defmodule Infrastructure.Repository.Models.Commerce.TransferableAdventure do
  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset

  alias Infrastructure.Repository.Models
  alias Infrastructure.Repository.Models.Commerce

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @schema_prefix "commerce"

  @fields ~w(id adventure_id transferable_id inserted_at updated_at)a
  @required_fields ~w(id adventure_id transferable_id inserted_at updated_at)a

  schema "transferable_adventures" do
    belongs_to(:adventure, Models.Adventure)
    belongs_to(:transferable, Commerce.Transferable)
    timestamps()
  end

  def changeset(model, params) do
    model
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
