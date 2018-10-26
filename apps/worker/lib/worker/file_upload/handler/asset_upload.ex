defmodule Worker.FileUpload.Handler.AssetUpload do
  require Logger
  use Worker.FileUpload.Handler

  alias Infrastructure.Repository
  alias Infrastructure.Repository.Models.Asset

  @bucket Application.get_env(:worker, :asset_bucket)

  def process(%{body: %{"Records" => [s3_event]}} = event, queue_name) do
    s3_event
    |> case do
      %{"s3" => %{"bucket" => %{"name" => bucket}, "object" => %{"key" => path, "size" => size}}} ->
        {bucket |> valid_bucket?, path |> valid_path?, size |> valid_size?}
        |> case do
          {true, true, true} ->
            with {:ok, id} <- path |> id_from_path,
                 {:ok, type} <- path |> type_from_path do
              %Asset{}
              |> Asset.changeset(%{
                id: id,
                type: type,
                inserted_at: NaiveDateTime.utc_now(),
                updated_at: NaiveDateTime.utc_now()
              })
              |> Repository.insert(on_conflict: :nothing)
              |> case do
                {:ok, _} ->
                  purge(queue_name, event)
                  :ok

                _ ->
                  :ok
              end
            else
              _ -> :ok
            end

          {false, _, _} ->
            :ok

          {true, _, _} ->
            Logger.warn("Removing invalid file from #{bucket}@#{path}")

            remove_files(bucket, [path, "#{path |> Path.dirname()}/"])
            |> case do
              {:ok, _} ->
                purge(queue_name, event)

              _ ->
                nil
            end
        end
    end
  end

  def process(_, _) do
    :ok
  end

  def valid_bucket?(bucket) do
    bucket == @bucket
  end

  def valid_path?(path) do
    path
    |> Path.split()
    |> case do
      [id, "original" <> ext] ->
        with {:ok, _uuid} <- Ecto.UUID.cast(id),
             {:ok, _type} <- type_from_extension(ext) do
          true
        else
          _ -> false
        end

      _ ->
        false
    end
  end

  def id_from_path(path) do
    path
    |> Path.split()
    |> case do
      [id, "original" <> ext] ->
        {:ok, id}

      _ ->
        :error
    end
  end

  def valid_size?(size) do
    size > 0
  end

  def type_from_path(path) do
    path
    |> Path.extname()
    |> type_from_extension()
  end

  def type_from_extension(extension) when extension in [".jpeg", ".jpg", ".png"] do
    {:ok, "image"}
  end

  def type_from_extension(extension) when extension in [".mp4", ".webm"] do
    {:ok, "video"}
  end

  def type_from_extension(extension) when extension in [".mp3"] do
    {:ok, "audio"}
  end

  def type_from_extension(_) do
    :error
  end
end
