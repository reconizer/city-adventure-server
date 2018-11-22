defmodule Infrastructure.Repository.Models.User do

  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset
  alias Infrastructure.Repository.Models.{
    Ranking,
    UserPoint,
    UserAdventure
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :nick, :string
    field :email, :string
    field :password_digest, :string
    
    timestamps()

    has_many :rankings, Ranking
    has_many :user_points, UserPoint
    has_many :user_adventures, UserAdventure
  end

  def build(params) do
    changeset(%__MODULE__{}, params)
  end

  @params ~w()a
  @required_params ~w()a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @params)
    |> validate_required(@required_params)
  end

end
