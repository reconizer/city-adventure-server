defmodule Infrastructure.Repository.Models.CreatorFollower do
  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset

  alias Infrastructure.Repository.Models
  @primary_key false
  @foreign_key_type :binary_id

  schema "creator_followers" do
    belongs_to(:user, Models.User, foreign_key: :user_id)
    belongs_to(:creator, Models.Creator, foreign_key: :creator_id)

    timestamps()
  end

  def build(params) do
    changeset(%__MODULE__{}, params)
  end

  @params ~w(user_id creator_id inserted_at updated_at)a
  @required_params ~w(user_id creator_id)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @params)
    |> validate_required(@required_params)
    |> foreign_key_constraint(:creator_id)
    |> foreign_key_constraint(:user_id)
  end
end
