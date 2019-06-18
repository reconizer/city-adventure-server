defmodule Infrastructure.Repository.Models.CreatorAdventureMessage do
  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset

  alias Infrastructure.Repository.Models.{
    Creator,
    Adventure
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "creator_adventure_messages" do
    field(:content, :string)

    belongs_to(:creator, Creator)
    belongs_to(:adventure, Adventure)

    timestamps()
  end

  def build(params) do
    changeset(%__MODULE__{}, params)
  end

  @params ~w(id content creator_id inserted_at updated_at adventure_id)a
  @required_params ~w(id content creator_id inserted_at adventure_id)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @params)
    |> validate_required(@required_params)
  end
end
