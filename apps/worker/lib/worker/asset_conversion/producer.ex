defmodule Worker.AssetConversion.Producer do
  @moduledoc """
  Handles uploads made directly to S3. When a file is uploaded S3 sends messages to
  SQS. This module handles those SQS messages.
  """

  @message_handlers Application.get_env(:worker, :asset_conversion_handlers)
  @max_number_of_messages Application.get_env(:worker, :max_number_of_messages)

  require Logger
  use GenServer
  alias Infrastructure.Repository
  alias Infrastructure.Repository.Models.AssetConversion

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    Process.send(self(), :fetch_messages, [])
    {:ok, {}}
  end

  def handle_info(:fetch_messages, queue_name) do
    AssetConversion.pending_conversions(limit: @max_number_of_messages)
    |> Enum.map(&emit_message/1)
    |> Enum.count()
    |> case do
      @max_number_of_messages ->
        Process.send(self(), :fetch_messages, [])

      _ ->
        Process.send_after(self(), :fetch_messages, 2_000)
    end

    {:noreply, queue_name}
  end

  def emit_message(event) do
    @message_handlers
    |> Enum.map(&Task.start(&1, :process, [event]))
  end
end
