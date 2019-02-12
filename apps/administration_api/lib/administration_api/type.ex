defmodule AdministrationApi.Type do
  defmacro __using__(_env) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      @primary_key false
    end
  end
end
