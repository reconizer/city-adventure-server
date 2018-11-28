defmodule Worker.Helper.AssetConversionEvent.Path do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:bucket, :string)
    field(:path, :string)
  end

  @fields ~w(bucket path)a
  @required_fields @fields

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end

  def build(params) do
    %__MODULE__{}
    |> changeset(params)
    |> case do
      %{valid?: true} = changeset -> {:ok, changeset |> apply_changes}
      changeset -> {:error, changeset}
    end
  end
end
