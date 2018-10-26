defmodule Worker.FileUpload.Producer do
  @moduledoc """
  Handles uploads made directly to S3. When a file is uploaded S3 sends messages to
  SQS. This module handles those SQS messages.
  """

  @message_handlers Application.get_env(:worker, :file_upload_handlers)
  @max_number_of_messages Application.get_env(:worker, :max_number_of_messages)
  @queue_name Application.get_env(:worker, :file_upload_queue_name)

  require Logger
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    Process.send(self(), :fetch_messages, [])
    {:ok, []}
  end

  def handle_info(:fetch_messages, queue_name) do
    ExAws.SQS.receive_message(queue_name, max_number_of_messages: @max_number_of_messages)
    |> ExAws.request()
    |> case do
      {:ok, %{body: %{messages: messages}}} -> messages
    end
    |> Enum.map(&parse_body/1)
    |> Enum.map(&emit_message/1)
    |> Enum.count()
    |> case do
      @max_number_of_messages ->
        Process.send(self(), :fetch_messages, [])

      _ ->
        Process.send_after(self(), :fetch_messages, 10_000)
    end

    {:noreply, []}
  end

  def emit_message(event) do
    @message_handlers
    |> Enum.map(&Task.start(&1, :process, [event, @queue_name]))
  end

  def parse_body(%{body: body} = message) do
    %{message | body: body |> Poison.decode!()}
  end
end
