defmodule Worker.FileUpload.Handler.AssetUpload do
  require Logger
  use Worker.Handler
  alias Worker.Helper

  alias Infrastructure.Repository
  alias Infrastructure.Repository.Models.Asset

  @bucket Application.get_env(:worker, :asset_bucket)

  def process(%{body: %{"Records" => [_s3_event]}} = event, queue_name) do
    event
    |> Helper.AssetEvent.build_from_queue()
    |> case do
      {:ok, %{bucket: @bucket, file_name: "original"} = asset_event} ->
        {:ok, asset_event}

      {:ok, %{file_name: file_name} = asset_event} when file_name != "original" ->
        {:error, {:non_original_file, asset_event}}

      {:ok, asset_event} ->
        {:error, {:mismatched_bucket, asset_event}}

      error ->
        error
    end
    |> persist_asset
    |> send_conversions
    |> cleanup(queue_name)
  end

  def process(_, _), do: :ok

  def persist_asset({:ok, asset_event}) do
    Asset
    |> Repository.get(asset_event.asset_id)
    |> case do
      nil ->
        %Asset{}
        |> Asset.changeset(%{
          id: asset_event.asset_id,
          name: asset_event.file_name,
          extension: asset_event.extension,
          inserted_at: NaiveDateTime.utc_now(),
          updated_at: NaiveDateTime.utc_now(),
          uploaded: true,
          type: asset_event.type
        })
        |> Repository.insert()

      asset ->
        asset
        |> Asset.changeset(%{
          extension: asset_event.extension,
          uploaded: true,
          updated_at: NaiveDateTime.utc_now()
        })
        |> Repository.update()
    end
    |> case do
      {:ok, _} -> {:ok, asset_event}
      {:error, changeset} -> {:error, {:persistance_failed, changeset}}
    end
  end

  def persist_asset(other), do: other

  def cleanup({:ok, asset_event}, queue_name) do
    queue_name
    |> purge(asset_event.receipt_handle)
    |> case do
      {:ok, _} = result ->
        Logger.info("Asset `#{asset_event.asset_id}` of type `#{asset_event.type}` successfuly persisted.")
        result

      other ->
        other
    end
  end

  def cleanup({:error, {:persistance_failed, changeset}}, _queue_name) do
    Logger.error("Persisting asset failed:")
    Logger.error(changeset.error |> inspect)
    Module
    :ok
  end

  def cleanup({:error, {:mismatched_bucket, _asset_event}}, _queue_name) do
    :ok
  end

  def cleanup({:error, {:non_original_file, _asset_event}}, _queue_name) do
    :ok
  end

  def cleanup({:error, error}, queue_name) do
    bucket = error |> Ecto.Changeset.get_change(:bucket)
    path = error |> Ecto.Changeset.get_change(:path)
    receipt_handle = error |> Ecto.Changeset.get_change(:receipt_handle)
    Logger.warn("Removing invalid file from #{bucket}@#{path}")

    remove_files(bucket, [path, "#{path |> Path.dirname()}/"])
    |> case do
      {:ok, _} ->
        purge(queue_name, receipt_handle)

      _ ->
        nil
    end

    :ok
  end

  def cleanup(other, _) do
    Logger.warn("Unrecognized error:")
    Logger.warn(other |> inspect)

    :ok
  end

  def send_conversions({:ok, asset_event}) do
    asset_event
    |> Helper.AssetEvent.build_conversions()
    |> Enum.map(fn conversion ->
      send_message(conversion_queue_name(), conversion)
    end)

    {:ok, asset_event}
  end

  def send_conversions(other), do: other

  defp conversion_queue_name do
    Application.get_env(:worker, :conversion_queue_name)
  end
end
