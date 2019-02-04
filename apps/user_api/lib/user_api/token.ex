defmodule UserApi.Token do
  def create(user_id) do
    Phoenix.Token.sign(UserApiWeb.Endpoint, "user salt", user_id)
  end
end
