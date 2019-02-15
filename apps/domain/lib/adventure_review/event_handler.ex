defmodule Domain.AdventureReview.EventHandler do
  @handlers [
    Domain.AdventureReview.EventHandler.Adventure,
    Domain.AdventureReview.EventHandler.Message
  ]

  def process(multi, event) do
    @handlers
    |> Enum.reduce(multi, fn handler, multi ->
      handler.process(multi, event)
    end)
  end
end
