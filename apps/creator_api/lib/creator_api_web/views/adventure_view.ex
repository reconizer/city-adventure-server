defmodule CreatorApiWeb.AdventureView do
  use CreatorApiWeb, :view

  def render("item.json", %{item: item}) do
    %{
      id: item.id,
      name: item.name,
      description: item.description,
      language: item.language,
      difficulty: item.difficulty_level,
      duration: render_duration(item.min_time, item.max_time),
      shown: item.show,
      status: item.status,
      rating: item.rating |> render_rating(),
      cover_url: asset_url(item.asset),
      creator_id: item.creator_id,
      images: item.images |> Enum.map(&render_image/1)
    }
  end

  def render("upload_asset.json", %{adventure: %{asset: asset}}) do
    %{
      url: asset |> asset_upload_url()
    }
  end

  def render("upload_image.json", %{adventure: %{images: images}}) do
    asset = images |> get_asset_by_sort()

    %{
      url: asset |> asset_upload_url()
    }
  end

  def render("list.json", %{list: list}) do
    list
    |> Enum.map(&adventure_list_item/1)
  end

  def adventure_list_item(adventure) do
    %{
      id: adventure.id,
      name: adventure.name,
      shown: adventure.show,
      rating: adventure.rating |> render_rating(),
      status: adventure.status,
      cover_url: asset_url(adventure.asset)
    }
  end

  defp render_rating(nil), do: nil

  defp render_rating(val) do
    val
    |> Decimal.to_float()
    |> Float.round(2)
  end

  defp render_image(nil), do: nil

  defp render_image(image) do
    %{
      id: image.id,
      url: asset_url(image.asset),
      order: image.sort
    }
  end

  defp render_duration(nil, nil), do: nil

  defp render_duration(min, max) do
    %{
      min: min,
      max: max
    }
  end

  defp get_asset_by_sort([]) do
    nil
  end

  defp get_asset_by_sort(images) do
    images
    |> Enum.filter(fn image -> image.sort != nil end)
    |> Enum.max_by(fn image -> image.sort end)
    |> Map.get(:asset)
  end
end
