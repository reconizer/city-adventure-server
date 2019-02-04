defmodule Domain.Creator.EventHandler do
  @handlers [
    Domain.Creator.EventHandlers.User,
    Domain.Creator.EventHandlers.Adventure
  ]

  def process(multi, event) do
    @handlers
    |> Enum.reduce(multi, fn handler, multi ->
      handler.process(multi, event)
    end)
  end
end
