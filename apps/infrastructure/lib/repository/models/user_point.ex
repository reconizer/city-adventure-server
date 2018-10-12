defmodule Infrastructure.Repository.Models.UserPoint do

  @type t :: %__MODULE__{}

  use Ecto.Schema
  import Ecto.Changeset
  alias Infrastructure.Repository.Models.{
    Point,
    User
  }

  @primary_key false
  @foreign_key_type :binary_id

  schema "user_points" do
    field :completed, :boolean
    timestamps()

    belongs_to :point, Point, primary_key: true
    belongs_to :user, User, primary_key: true

  end

  def build(params) do
    changeset(%__MODULE__{}, params)
  end

  @params ~w(user_id point_id)a
  @required_params ~w(point_id user_id)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @params)
    |> validate_required(@required_params)
    |> foreign_key_constraint(:point_id)
    |> foreign_key_constraint(:user_id)
  end

end
