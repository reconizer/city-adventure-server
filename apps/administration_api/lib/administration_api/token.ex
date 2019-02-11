defmodule AdministrationApi.Token do
  def create({:ok, user_id}), do: create(user_id)
  def create

  def create(user_id) do
    token = Phoenix.Token.sign(AdministrationApiWeb.Endpoint, "user salt", user_id)
    {:ok, token}
  end
end
