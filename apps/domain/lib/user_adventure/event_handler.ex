defmodule Domain.UserAdventure.EventHandler do
  @handlers [
    Domain.UserAdventure.EventHandlers.Adventure
  ]

  def process(multi, event) do
    @handlers
    |> Enum.reduce(multi, fn handler, multi ->
      handler.process(multi, event)
    end)
  end
end
