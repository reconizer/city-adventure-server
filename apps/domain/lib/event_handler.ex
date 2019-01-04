defmodule Domain.EventHandler do
  defmacro __using__(_env) do
    quote do
      @before_compile Domain.EventHandler
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def process(multi, _event) do
        multi
      end
    end
  end

  def emit(event) do
    Application.get_env(:domain, :event_handlers)
    |> Enum.reduce(Ecto.Multi.new(), fn event_handler, multi ->
      event_handler.process(multi, event)
    end)
    |> case do
      multi -> {:ok, multi}
    end
  end
end
