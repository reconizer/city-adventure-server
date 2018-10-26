defmodule Worker.FileUpload.Handler.RemoveTestEvent do
  use Worker.FileUpload.Handler

  def process(%{body: %{"Event" => "s3:TestEvent"}} = event, queue_name) do
    purge(queue_name, event)

    :ok
  end

  def process(_, _) do
    :ok
  end
end
