defmodule Worker.Helper.AssetConversionEvent do
  use Ecto.Schema
  import Ecto.Changeset

  alias Worker.Helper.AssetConversionEvent

  @primary_key false
  embedded_schema do
    field(:topic, :string)
    embeds_many(:conversions, AssetConversionEvent.Conversion)
    embeds_one(:source, AssetConversionEvent.Path)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:topic])
    |> validate_required([:topic])
    |> cast_embed(:conversions, required: true)
    |> cast_embed(:source, required: true)
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
