defmodule AdministrationApiWeb.Contracts do
  import Contract

  def with_administrator(params, conn) do
    administrator_id = conn.assigns |> Map.get(:administrator_id)

    params
    |> Map.merge(%{"administrator_id" => administrator_id})
  end
end
