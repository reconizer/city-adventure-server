defmodule UserApiWeb.ViewHelpers do
  alias Infrastructure.Service.AssetManagement

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
    end
  end

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

  def asset_url(%{type: type, extension: extension, id: id, name: name}) do
    {:ok, url} = AssetManagement.download_url(type, id, name, extension)
    url
  end

  def asset_url(%{}) do
    nil
  end
end
