defmodule Infrastructure.Repository.Models.Creator do
  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset

  alias Infrastructure.Repository.Models.{
    Adventure,
    Asset
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "creators" do
    field(:description, :string)
    field(:name, :string)
    field(:address1, :string)
    field(:address2, :string)
    field(:city, :string)
    field(:country, :string)
    field(:email, :string)
    field(:password_digest, :string)
    field(:zip_code, :string)
    field(:approved, :boolean)

    timestamps()

    has_many(:adventures, Adventure)
    belongs_to(:asset, Asset)
  end

  def build(params) do
    changeset(%__MODULE__{}, params)
  end

  @params ~w(description name address1 address2 city country email password_digest zip_code approved asset_id)a
  @required_params ~w(name email password_digest)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @params)
    |> validate_required(@required_params)
    |> unique_constraint(:email)
  end
end
