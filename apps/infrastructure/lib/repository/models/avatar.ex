defmodule Infrastructure.Repository.Models.Avatar do
  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset

  alias Infrastructure.Repository.Models.{
    User,
    Asset
  }

  @primary_key false
  @foreign_key_type :binary_id

  schema "avatars" do
    timestamps()

    belongs_to(:user, User, primary_key: true)
    belongs_to(:asset, Asset)
  end

  def build(params) do
    changeset(%__MODULE__{}, params)
  end

  @params ~w(user_id asset_id)a
  @required_params ~w(user_id asset_id)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @params)
    |> validate_required(@required_params)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:asset_id)
  end
end
