defmodule Domain.Profile.Repository.User do
  import Ecto.Query
  alias Ecto.UUID
  alias Infrastructure.Repository
  use Infrastructure.Repository.Models

  def get_by_email(email) do
    from(u in Models.User,
      where: u.email == ^email
    )
    |> Repository.one()
    |> case do
      nil -> {:error, :user_not_found}
      result -> {:ok, result}
    end
  end

end