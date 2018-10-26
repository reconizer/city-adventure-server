defmodule Worker.AssetConversion.Handler.SetEventSent do
  alias Infrastructure.Repository
  alias Infrastructure.Repository.Models.AssetConversion

  def process(%AssetConversion{} = asset_conversion) do
    asset_conversion
    |> AssetConversion.changeset(%{
      sent: true,
      updated_at: NaiveDateTime.utc_now()
    })
    |> Repository.update()
  end

  def process(_) do
    :ok
  end
end
