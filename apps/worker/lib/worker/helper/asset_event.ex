defmodule Worker.Helper.AssetEvent do
  use Ecto.Schema
  import Ecto.Changeset

  alias Worker.Helper.AssetConversionEvent

  @primary_key false
  embedded_schema do
    field(:asset_id, Ecto.UUID)
    field(:type, :string)
    field(:extension, :string)

    field(:file_name)
    field(:path)
    field(:bucket)
    field(:size, :integer)

    field(:receipt_handle)
  end

  @fields ~w(path bucket size receipt_handle file_name asset_id type extension)a
  @required_fields @fields

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> validate_number(:size, greater_than: 0)
  end

  def build(params) do
    %__MODULE__{}
    |> changeset(params)
    |> case do
      %{valid?: true} = changeset -> {:ok, changeset |> apply_changes}
      changeset -> {:error, changeset}
    end
  end

  def build_from_queue(params) do
    params
    |> case do
      %{body: body, receipt_handle: receipt_handle} ->
        %{"Records" => [%{"s3" => %{"bucket" => %{"name" => bucket}, "object" => %{"key" => path, "size" => size}}}]} = body

        build(%{
          bucket: bucket,
          path: path,
          size: size,
          receipt_handle: receipt_handle,
          file_name: path |> file_name_from_path,
          asset_id: path |> asset_id_from_path,
          type: path |> type_from_path,
          extension: path |> extension_from_path
        })
    end
  end

  defp asset_id_from_path(path) do
    path
    |> Path.split()
    |> Enum.at(1)
  end

  defp type_from_path(path) do
    path
    |> Path.split()
    |> Enum.at(0)
  end

  defp extension_from_path(path) do
    path
    |> Path.extname()
    |> case do
      "." <> ext -> ext
    end
  end

  defp file_name_from_path(path) do
    path
    |> Path.basename(path |> Path.extname())
  end

  def build_conversions(%{type: "clue_video"} = asset_event) do
    {:ok, conversion} =
      AssetConversionEvent.build(%{
        topic: "process_video",
        source: %{bucket: asset_event.bucket, path: asset_event.path},
        conversions: [
          %{
            destination: set_destination(asset_event, "320p.#{asset_event.extension}"),
            options: [
              %{
                name: "resize",
                params: %{
                  height: 320
                }
              }
            ]
          },
          %{
            destination: set_destination(asset_event, "thumb.png"),
            options: [
              %{
                name: "create_thumbnail",
                params: %{}
              }
            ]
          }
        ]
      })

    [conversion]
  end

  def build_conversions(%{type: "clue_image"} = asset_event) do
    {:ok, conversion} =
      AssetConversionEvent.build(%{
        topic: "process_image",
        source: %{bucket: asset_event.bucket, path: asset_event.path},
        conversions: [
          %{
            destination: set_destination(asset_event, "800x600.#{asset_event.extension}"),
            options: [
              %{
                name: "resize",
                params: %{
                  width: 800,
                  height: 600,
                  format: asset_event.extension,
                  gravity: "Center"
                }
              }
            ]
          }
        ]
      })

    [conversion]
  end

  def build_conversions(_) do
    []
  end

  def set_destination(asset_event, name) do
    %{bucket: asset_event.bucket, path: [asset_event.type, asset_event.asset_id, name] |> Path.join()}
  end
end
