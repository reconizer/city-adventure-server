defmodule Domain.Creator.Service.Adventure do
  alias Domain.Creator.User
  alias Domain.Creator.Adventure
  alias Domain.Creator.Repository.User, as: UserRepository
  alias Domain.Creator.Repository.Adventure, as: AdventureRepository

  @spec get_creator(any()) :: {:error, :not_found} | {:ok, Domain.Creator.User.t()}
  def get_creator(creator_id) do
    UserRepository.get(creator_id)
  end

  @spec get_creator_adventures(any()) :: {:error, :not_found} | {:ok, [User.Adventure.t()]}
  def get_creator_adventures(creator_id) do
    get_creator(creator_id)
    |> case do
      {:ok, user} -> {:ok, user.adventures}
      error -> error
    end
  end

  @spec get_creator_adventure(any(), any()) :: {:error, :not_found} | {:ok, Adventure.t()}
  def get_creator_adventure(creator_id, adventure_id) do
    get_creator(creator_id)
    |> case do
      {:ok, user} ->
        user
        |> User.get_adventure(adventure_id)
        |> case do
          {:ok, adventure} ->
            AdventureRepository.get(adventure.id)

          error ->
            error
        end

      error ->
        error
    end
  end
end
