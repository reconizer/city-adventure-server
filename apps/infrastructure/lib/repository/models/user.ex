defmodule Infrastructure.Repository.Models.User do
  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset

  alias Infrastructure.Repository.Models.{
    Ranking,
    UserPoint,
    UserAdventure,
    Avatar,
    Commerce
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field(:nick, :string)
    field(:email, :string)
    field(:password_digest, :string)

    timestamps()

    has_one(:user_account, Commerce.UserAccount)
    has_one(:account, through: [:user_account, :account])
    has_one(:avatar, Avatar)

    has_many(:rankings, Ranking)
    has_many(:user_points, UserPoint)
    has_many(:user_adventures, UserAdventure)
  end

  def build(params) do
    changeset(%__MODULE__{}, params)
  end

  @params ~w(nick email password_digest inserted_at updated_at)a
  @required_params ~w()a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @params)
    |> cast_assoc(:user_account)
    |> cast_assoc(:account)
    |> validate_required(@required_params)
  end
end
