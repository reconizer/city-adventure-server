defmodule Worker.FileUpload.Handler do
  defmacro __using__(_env) do
    quote do
      @callback process(_ :: any, _ :: any) :: :ok

      import Worker.FileUpload.Handler
    end
  end

  def purge(queue_name, %{receipt_handle: receipt_handle} = _event) do
    queue_name
    |> ExAws.SQS.delete_message(receipt_handle)
    |> ExAws.request()
  end

  def remove_files(bucket, paths) do
    require Logger

    bucket
    |> ExAws.S3.delete_multiple_objects(paths)
    |> ExAws.request()
    |> case do
      {:error, _} = error -> Logger.warn(error)
      other -> other
    end
  end

  def remove_file(bucket, path) do
    require Logger

    bucket
    |> ExAws.S3.delete_object(path)
    |> ExAws.request()
    |> case do
      {:error, _} = error -> Logger.warn(error)
      other -> other
    end
  end
end
