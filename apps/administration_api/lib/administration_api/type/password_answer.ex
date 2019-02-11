defmodule AdministrationApi.Type.PasswordAnswer do
  @behaviour Ecto.Type
  use AdministrationApi.Type

  embedded_schema do
    field(:type, :string)
    field(:password, :string)
  end

  @fields ~w(type password)a
  @required_fields ~w(type password)a

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end

  def cast(%{"type" => type, "password" => password}) do
    changeset =
      %AdministrationApi.Type.PasswordAnswer{}
      |> changeset(%{
        type: type,
        password: password
      })

    cond do
      changeset.valid? ->
        {:ok,
         %{
           type: type,
           password: password
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
