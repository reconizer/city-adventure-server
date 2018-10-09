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
      nil -> {:error, {:user, "not_found"}}
      result -> {:ok, result}
    end
  end

  def get_by_id(id) do
    from(u in Models.User,
      where: u.id == ^id
    )
    |> Repository.one()
    |> case do
      nil -> {:error, {:user, "not_found"}}
      result -> {:ok, result}
    end
  end

end