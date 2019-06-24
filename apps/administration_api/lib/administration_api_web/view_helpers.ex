defmodule AdministrationApiWeb.ViewHelpers do
  alias Infrastructure.Service.AssetManagement

  def asset_url(nil) do
    nil
  end

  def asset_url(%Infrastructure.Repository.Models.Asset{} = asset) do
    {:ok, url} = AssetManagement.download_url(asset)
    url
  end

  def asset_url(%Infrastructure.Repository.Models.AssetConversion{} = asset) do
    {:ok, url} = AssetManagement.download_url(asset)
    url
  end

  def asset_url(%{type: type, extension: extension, asset_id: id, name: name}) do
    {:ok, url} = AssetManagement.download_url(type, id, name, extension)
    url
  end

  def asset_url(%{type: type, extension: extension, id: id, name: name}) do
    {:ok, url} = AssetManagement.download_url(type, id, name, extension)
    url
  end

  def asset_url(%{}) do
    nil
  end
end
