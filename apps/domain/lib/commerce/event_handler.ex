defmodule Domain.Commerce.EventHandler do
  @handlers [
    Domain.Commerce.Transfer.EventHandler
  ]

  def process(multi, event) do
    @handlers
    |> Enum.reduce(multi, fn handler, multi ->
      handler.process(multi, event)
    end)
  end
end
