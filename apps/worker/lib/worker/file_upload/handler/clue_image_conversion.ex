defmodule Worker.FileUpload.Handler.ClueImageConversion do
  require Logger
  use Worker.Handler
  alias Worker.Helper

  alias Infrastructure.Repository
  alias Infrastructure.Repository.Models.AssetConversion

  @bucket Application.get_env(:worker, :asset_bucket)
  @available_conversions []

  def process(%{body: %{"Records" => [_s3_event]}} = event, queue_name) do
    event
    |> Helper.AssetEvent.build_from_queue()
    |> case do
      {:ok, %{bucket: @bucket, type: "clue_image", file_name: file_name} = asset_event} when file_name in @available_conversions ->
        {:ok, asset_event}

      {:ok, asset_event} ->
        {:error, {:invalid_conversion, asset_event}}

      error ->
        error
    end
    |> persist_asset_conversion
    |> cleanup(queue_name)
  end

  def process(_, _), do: :ok

  def persist_asset_conversion({:ok, asset_event}) do
    AssetConversion
    |> Repository.get_by(%{asset_id: asset_event.asset_id, name: asset_event.file_name})
    |> case do
      nil ->
        %AssetConversion{}
        |> AssetConversion.changeset(%{
          id: Ecto.UUID.generate(),
          asset_id: asset_event.asset_id,
          name: asset_event.file_name,
          type: asset_event.type,
          extension: asset_event.extension,
          inserted_at: NaiveDateTime.utc_now(),
          updated_at: NaiveDateTime.utc_now()
        })
        |> Repository.insert()

      asset ->
        asset
        |> AssetConversion.changeset(%{
          extension: asset_event.extension,
          updated_at: NaiveDateTime.utc_now()
        })
        |> Repository.update()
    end
    |> case do
      {:ok, _} -> {:ok, asset_event}
      {:error, changeset} -> {:error, {:persistance_failed, changeset}}
    end
  end

  def persist_asset_conversion(error), do: error

  def cleanup({:ok, asset_event}, queue_name) do
    queue_name
    |> purge(asset_event.receipt_handle)
    |> case do
      {:ok, _} = result ->
        Logger.info("Asset conversion `#{asset_event.file_name}` for asset `#{asset_event.asset_id}` successfuly persisted.")
        result

      other ->
        other
    end
  end

  def cleanup({:error, {:persistance_failed, changeset}}, _queue_name) do
    Logger.error("Persisting asset failed:")
    Logger.error(changeset.error |> inspect)

    :ok
  end

  def cleanup({:error, _} = _e, _queue_name) do
    :ok
  end
end
