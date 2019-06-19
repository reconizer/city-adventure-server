defmodule AdministrationApi.Type.TimeAnswer do
  @behaviour Ecto.Type
  use AdministrationApi.Type

  embedded_schema do
    field(:start_time, :integer)
    field(:duration, :integer)
  end

  @fields ~w(start_time duration)a
  @required_fields ~w(start_time duration)a

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end

  def cast(%{"start_time" => start_time, "duration" => duration}) do
    changeset =
      %AdministrationApi.Type.TimeAnswer{}
      |> changeset(%{
        start_time: start_time,
        duration: duration
      })

    cond do
      changeset.valid? ->
        {:ok,
         %{
           start_time: changeset.changes.start_time,
           duration: changeset.changes.duration
         }}

      true ->
        :error
    end
  end

  def cast(_) do
    :error
  end

  def type() do
  end

  def load(_) do
    {:ok, nil}
  end

  def dump(_) do
    {:ok, nil}
  end
end
