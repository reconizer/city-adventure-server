defmodule CreatorApiWeb.ClueView do
  use CreatorApiWeb, :view

  def render("item.json", %{item: %{asset: nil} = clue}) do
    %{
      id: clue.id,
      type: clue.type,
      point_id: clue.point_id,
      description: clue.description,
      order: clue.sort,
      tip: clue.tip,
      url: clue.url,
      video_url: nil
    }
  end

  def render("item.json", %{item: %{asset: %{asset_conversions: []} = asset} = clue}) do
    %{
      id: clue.id,
      type: clue.type,
      point_id: clue.point_id,
      description: clue.description,
      order: clue.sort,
      tip: clue.tip,
      url: asset |> asset_url(),
      video_url: nil
    }
  end

  def render("item.json", %{item: %{asset: %{asset_conversions: conversions} = asset} = clue}) do
    %{
      id: clue.id,
      type: clue.type,
      point_id: clue.point_id,
      description: clue.description,
      order: clue.sort,
      tip: clue.tip,
      url: conversions |> render_thumb(),
      video_url: asset |> asset_url()
    }
  end

  def render("upload_asset.json", %{clue: %{asset: asset}}) do
    %{
      url: asset |> asset_upload_url()
    }
  end

  defp render_thumb(conversions) do
    conversions
    |> Enum.find(fn conversion ->
      conversion.name == "thumb"
    end)
    |> case do
      nil ->
        nil

      result ->
        result
        |> asset_url()
    end
  end
end
