defmodule CreatorApi.Token do
  def create(user_id) do
    Phoenix.Token.sign(CreatorApiWeb.Endpoint, "user salt", user_id)
  end
end
