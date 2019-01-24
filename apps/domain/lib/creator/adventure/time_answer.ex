defmodule Domain.Creator.Adventure.TimeAnswer do
  use Ecto.Schema
  import Ecto.Changeset, only: [cast: 3, validate_required: 2, cast_embed: 2, apply_changes: 1, validate_change: 3, get_field: 2]

  alias Domain.Creator.Adventure

  @type t :: %__MODULE__{}
  @type ok_t :: t() | {:ok, t()}
  @type error :: {:error, any()}

  @primary_key false
  embedded_schema do
    field(:start_time, :integer)
    field(:duration, :integer)
  end

  @fields ~w(start_time duration)a
  @required_fields @fields

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end

  def new(%{start_time: start_time, duration: duration}) do
    %Adventure.Clue{
      id: Ecto.UUID.generate()
    }
    |> changeset(%{
      start_time: start_time,
      duration: duration
    })
    |> case do
      %{valid?: true} = changeset ->
        {:ok, changeset |> apply_changes}

      changeset ->
        {:error, changeset}
    end
  end

  @spec change(ok_t(), Map.t()) :: ok_t | error
  def change({:ok, time_answer}, time_answer_params), do: change(time_answer, time_answer_params)
  def change({:error, _} = error, _), do: error

  def change(time_answer, time_answer_params) do
    time_answer
    |> Adventure.TimeAnswer.changeset(time_answer_params)
    |> case do
      %{valid?: true} = changeset ->
        {:ok, {changeset |> apply_changes, changeset.changes}}

      changeset ->
        {:error, changeset}
    end
  end
end
