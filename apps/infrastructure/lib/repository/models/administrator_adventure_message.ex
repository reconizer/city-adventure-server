defmodule Infrastructure.Repository.Models.AdministratorAdventureMessage do
  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset

  alias Infrastructure.Repository.Models.{
    Administrator,
    Adventure
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "administrator_adventure_messages" do
    field(:content, :string)

    belongs_to(:administrator, Administrator)
    belongs_to(:adventure, Adventure)

    timestamps()
  end

  def build(params) do
    changeset(%__MODULE__{}, params)
  end

  @params ~w(id content administrator_id inserted_at updated_at adventure_id)a
  @required_params ~w(id content administrator_id inserted_at adventure_id)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @params)
    |> validate_required(@required_params)
  end
end
