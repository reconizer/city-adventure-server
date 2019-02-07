defmodule Domain.UserAdventure.Point do
  alias Domain.UserAdventure.{
    Point,
    Clue,
    Answer
  }

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:last_point, :boolean, default: false)
    field(:answer_type, :string)
    field(:position, Geo.PostGIS.Geometry)
    field(:show, :boolean)
    field(:radius, :integer)
    field(:parent_point_id, Ecto.UUID)
    field(:adventure_id, Ecto.UUID)
    embeds_many(:clues, Clue)
    embeds_many(:answers, Answer)

    timestamps()
  end

  @fields [:position, :show, :radius, :parent_point_id, :adventure_id, :id]
  @required_fields @fields

  @spec changeset(Point.t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:clues)
  end

  def set_last_point(%Point{} = point, points) do
    points
    |> Enum.find(fn p ->
      p.parent_point_id == point.id
    end)
    |> case do
      nil ->
        point
        |> Map.put(:last_point, true)

      _result ->
        point
        |> Map.put(:last_point, false)
    end
  end

  def set_answer_type(%Point{} = point) do
    point
    |> Map.get(:answers)
    |> case do
      nil ->
        point

      result ->
        result
        |> Enum.find(fn answer ->
          answer.type == "password"
        end)
        |> case do
          nil ->
            point

          %{details: %{"password_type" => type}} ->
            point
            |> Map.put(:answer_type, type)
        end
    end
  end

  def check_last_point(%Point{} = point) do
    point.last_point
  end
end
