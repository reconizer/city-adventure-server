defmodule Infrastructure.Repository.Models.Image do

  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset
  alias Infrastructure.Repository.Models.{
    Adventure
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "images" do
    timestamps()

    belongs_to :adventure, Adventure
  end

  def build(params) do
    changeset(%__MODULE__{}, params)
  end

  @params ~w(adventure_id)a
  @required_params ~w(adventure_id)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @params)
    |> validate_required(@required_params)
    |> foreign_key_constraint(:adventure_id)
  end

end
