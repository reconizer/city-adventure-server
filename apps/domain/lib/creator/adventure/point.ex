defmodule Domain.Creator.Adventure.Point do
  use Ecto.Schema
  import Ecto.Changeset, only: [cast: 3, validate_required: 2, cast_embed: 2, cast_embed: 3, apply_changes: 1, validate_change: 3, get_field: 2]

  alias Domain.Creator.Adventure

  @type t :: %__MODULE__{}
  @type aggregate_result :: t() | {:ok, t()} | {:error, any()}

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:parent_point_id, :binary_id)
    field(:radius, :integer)
    field(:show, :boolean)

    embeds_one(:position, Adventure.Position, on_replace: :update)
    embeds_many(:clues, Adventure.Clue)
    embeds_one(:time_answer, Adventure.TimeAnswer, on_replace: :update)
    embeds_one(:password_answer, Adventure.PasswordAnswer)
  end

  @fields ~w(id parent_point_id radius show)a
  @required_fields @fields -- [:parent_point_id]

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> validate_parent_point()
    |> cast_embed(:position)
    |> cast_embed(:time_answer)
    |> cast_embed(:password_answer)
    |> cast_embed(:clues)
  end

  def new(%{id: id, parent_point_id: parent_point_id, radius: radius, show: show, lat: lat, lng: lng}) do
    %Adventure.Point{
      id: id
    }
    |> changeset(%{
      parent_point_id: parent_point_id,
      radius: radius,
      show: show,
      position: %{lat: lat, lng: lng}
    })
    |> case do
      %{valid?: true} = changeset ->
        {:ok, changeset |> apply_changes}

      changeset ->
        {:error, changeset}
    end
  end

  def change({:ok, point}, point_params), do: change(point, point_params)
  def change({:error, _} = error, _), do: error

  def change(point, point_params) do
    point
    |> Adventure.Point.changeset(point_params)
    |> case do
      %{valid?: true} = changeset ->
        {:ok, {changeset |> apply_changes, changeset.changes}}

      changeset ->
        {:error, changeset}
    end
  end

  def get_clue({:ok, point}, clue_id), do: get_clue(point, clue_id)
  def get_clue({:error, _} = error, _), do: error
  @spec get_clue(Adventure.Point.t(), Ecto.UUID.t()) :: {:ok, Adventure.Clue.t()} | {:error, any()}
  def get_clue(point, clue_id) do
    point.clues
    |> Enum.find(&(&1.id == clue_id))
    |> case do
      nil -> {:error, {:clue_id, "not found in point"}}
      clue -> {:ok, clue}
    end
  end

  def add_clue({:ok, point}, clue), do: add_clue(point, clue)
  def add_clue({:error, _} = error, _), do: error

  def add_clue(point, new_clue) do
    new_clues = (point.clues ++ [new_clue]) |> Enum.sort_by(& &1.sort) |> Enum.reverse()

    {:ok, %{point | clues: new_clues}}
  end

  def remove_clue({:ok, point}, clue_id), do: remove_clue(point, clue_id)
  def remove_clue({:error, _} = error, _), do: error

  def remove_clue(point, clue_id) do
    new_clues = point.clues |> Enum.reject(&(&1.id == clue_id))

    {:ok, %{point | clues: new_clues}}
  end

  def replace_clue({:error, _} = error, _), do: error
  def replace_clue({:ok, point}, clue), do: replace_clue(point, clue)

  def replace_clue(point, %{id: clue_id} = clue) do
    point
    |> remove_clue(clue_id)
    |> case do
      {:ok, point} ->
        point
        |> add_clue(clue)

      error ->
        error
    end
  end

  def last_clue_sort(point) do
    point.clues
    |> case do
      [] -> 0
      [clue | _] -> clue.sort + 1
    end
  end

  defp validate_parent_point(changeset, options \\ []) do
    validate_change(changeset, :parent_point_id, fn field, parent_point_id ->
      id = changeset |> get_field(:id)

      cond do
        id == parent_point_id -> [{field, options[:message] || "Parent point id must differ from id"}]
        true -> []
      end
    end)
  end
end
