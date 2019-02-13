defmodule Infrastructure.Service.AssetManagement do
  alias Infrastructure.Repository.Models.Asset
  alias Infrastructure.Repository.Models.AssetConversion

  @spec download_url(Asset.t() | AssetConversion.t()) :: {:error, String.t()} | {:ok, String.t()}
  def download_url(%Asset{id: id, type: type, extension: extension, name: name, uploaded: true}) do
    download_url(type, id, name, extension)
  end

  def download_url(%Asset{id: id, type: type, extension: extension, name: name, uploaded: false}) do
    download_url(type, id, name, extension)
  end

  def download_url(%AssetConversion{asset_id: id, type: type, extension: extension, name: name}) do
    download_url(type, id, name, extension)
  end

  @spec download_url(String.t(), String.t(), String.t(), String.t()) :: {:error, String.t()} | {:ok, String.t()}
  def download_url(type, id, name, extension) do
    path =
      [type, id, name]
      |> Path.join()

    "#{path}.#{extension}"
    |> MediaStorage.download_url(bucket: bucket())
  end

  @spec upload_url(String.t(), String.t(), String.t()) :: {:error, String.t()} | {:ok, String.t()}
  def upload_url(type, id, extension) do
    path =
      [type, id, "original"]
      |> Path.join()

    "#{path}.#{extension}"
    |> MediaStorage.upload_url(bucket: bucket())
  end

  def bucket do
    Application.get_env(:infrastructure, :asset_bucket)
  end
end
