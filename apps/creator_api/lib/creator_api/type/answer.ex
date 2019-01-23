defmodule CreatorApi.Type.Answer do
  use CreatorApi.Type

  embedded_schema do
    field(:type, :string)
    field(:details, :map)
    field(:deleted, :boolean, default: false)
  end

  @fields ~w(type details deleted)a
  @required_fields @fields

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end

  def cast(%{"type" => "password", "answer" => answer}) do
    changeset =
      %CreatorApi.Type.Answer{}
      |> changeset(%{
        type: "password",
        details: %{
          password_type: "text",
          password: answer
        }
      })

    cond do
      changeset.valid? ->
        {:ok, apply_changes(changeset)}

      true ->
        :error
    end
  end

  def cast(%{"type" => "time", "starting_time" => starting_time, "duration" => duration}) do
    changeset =
      %CreatorApi.Type.Answer{}
      |> changeset(%{
        type: "time",
        details: %{
          starting_time: starting_time,
          duration: duration
        }
      })

    cond do
      changeset.valid? ->
        {:ok, apply_changes(changeset)}

      true ->
        :error
    end
  end
end
