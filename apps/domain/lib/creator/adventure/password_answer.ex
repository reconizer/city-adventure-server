defmodule Domain.Creator.Adventure.PasswordAnswer do
  use Ecto.Schema
  import Ecto.Changeset, only: [cast: 3, validate_required: 2, apply_changes: 1, validate_inclusion: 3]

  alias Domain.Creator.Adventure

  @type t :: %__MODULE__{}
  @type ok_t :: {:ok, t()}
  @type error :: {:error, any()}
  @type entity :: ok_t() | error()
  @type entity_changeset :: {:ok, {t(), Map.t()}} | error()

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:type, :string)
    field(:password, :string)
  end

  @fields ~w(type password)a
  @required_fields @fields
  @valid_types ~w(
    text
    number_lock_3
    number_lock_4
    number_lock_5
    number_lock_6
    cryptex_lock_4
    cryptex_lock_5
    cryptex_lock_6
    cryptex_lock_7
    direction_lock_4
    direction_lock_6
    direction_lock_8
    number_push_lock_3
    number_push_lock_4
    number_push_lock_5
  )

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:type, @valid_types)
  end

  def new(%{type: type, password: password}) do
    %Adventure.Clue{
      id: Ecto.UUID.generate()
    }
    |> changeset(%{
      type: type,
      password: password
    })
    |> case do
      %{valid?: true} = changeset ->
        {:ok, changeset |> apply_changes}

      changeset ->
        {:error, changeset}
    end
  end

  @spec change(t() | entity(), Map.t()) :: entity_changeset
  def change({:ok, password_answer}, password_answer_params), do: change(password_answer, password_answer_params)
  def change({:error, _} = error, _), do: error

  def change(password_answer, password_answer_params) do
    password_answer
    |> Adventure.PasswordAnswer.changeset(password_answer_params)
    |> case do
      %{valid?: true} = changeset ->
        {:ok, {changeset |> apply_changes, changeset.changes}}

      changeset ->
        {:error, changeset}
    end
  end
end
