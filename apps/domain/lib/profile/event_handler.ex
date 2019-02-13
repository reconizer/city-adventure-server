defmodule Domain.Profile.EventHandler do
  @handlers [
    Domain.Profile.EventHandlers.Registration
  ]

  def process(multi, event) do
    @handlers
    |> Enum.reduce(multi, fn handler, multi ->
      handler.process(multi, event)
    end)
  end
end
