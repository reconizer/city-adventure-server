defmodule Domain.UserAdventure.EventHandler do
  use Domain.EventHandler

  @handlers [
    Domain.UserAdventure.EventHandlers.Adventure
  ]

  def process(multi, event) do
    IO.inspect "process"
    @handlers
    |> Enum.reduce(multi, fn handler, multi ->
      handler.process(multi, event)
    end)
  end
end
