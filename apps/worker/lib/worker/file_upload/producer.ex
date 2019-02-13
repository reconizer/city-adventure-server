defmodule Worker.FileUpload.Producer do
  @moduledoc """
  Handles uploads made directly to S3. When a file is uploaded S3 sends messages to
  SQS. This module handles those SQS messages.
  """

  require Logger
  use GenServer

  def start_link(queue_name) do
    GenServer.start_link(__MODULE__, queue_name, name: __MODULE__)
  end

  def init(queue_name) do
    Process.send(self(), :fetch_messages, [])
    {:ok, queue_name}
  end

  def handle_info(:fetch_messages, queue_name) do
    max_number_of_messages = max_number_of_messages()

    ExAws.SQS.receive_message(queue_name, max_number_of_messages: max_number_of_messages())
    |> ExAws.request()
    |> case do
      {:ok, %{body: %{messages: messages}}} -> messages
    end
    |> Enum.map(&parse_body/1)
    |> Enum.map(&emit_message(&1, queue_name))
    |> Enum.count()
    |> case do
      max_number_of_messages ->
        Process.send(self(), :fetch_messages, [])

      _ ->
        Process.send_after(self(), :fetch_messages, 10_000)
    end

    {:noreply, queue_name}
  end

  def emit_message(event, queue_name) do
    message_handlers()
    |> Enum.map(&Task.start(&1, :process, [event, queue_name]))
  end

  def parse_body(%{body: body} = message) do
    %{message | body: body |> Poison.decode!()}
  end

  def message_handlers do
    Application.get_env(:worker, :file_upload_handlers)
  end

  def max_number_of_messages do
    Application.get_env(:worker, :max_number_of_messages)
  end
end
