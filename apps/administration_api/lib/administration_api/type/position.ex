defmodule AdministrationApi.Type.Position do
  @behaviour Ecto.Type
  use AdministrationApi.Type

  embedded_schema do
    field(:lat, :float)
    field(:lng, :float)
  end

  @fields ~w(lat lng)a
  @required_fields ~w(lat lng)a

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end

  def cast(%{"lat" => lat, "lng" => lng}) do
    changeset =
      %AdministrationApi.Type.Position{}
      |> changeset(%{
        lat: lat,
        lng: lng
      })

    cond do
      changeset.valid? ->
        {:ok,
         %{
           lat: changeset.changes.lat,
           lng: changeset.changes.lng
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
