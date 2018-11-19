defmodule Worker.Helper.AssetConversionEvent.Conversion do
  use Ecto.Schema
  import Ecto.Changeset

  alias Worker.Helper.AssetConversionEvent

  @primary_key false
  embedded_schema do
    embeds_one(:destination, AssetConversionEvent.Path)
    embeds_many(:options, AssetConversionEvent.Option)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [])
    |> cast_embed(:destination)
    |> cast_embed(:options)
  end
end
