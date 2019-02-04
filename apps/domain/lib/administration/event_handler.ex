defmodule Domain.Administration.EventHandler do
  alias Domain.Administration.EventHandler

  @handlers [
    EventHandler.User
  ]

  def process(multi, event) do
    @handlers
    |> Enum.reduce(multi, fn handler, multi ->
      handler.process(multi, event)
    end)
  end
end
