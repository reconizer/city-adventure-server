defmodule Domain.AdventureReview.Repository.Adventure do
  use Infrastructure.Repository.Models
  use Domain.Repository
  alias Infrastructure.Repository
  alias Infrastructure.Repository.Models
  import Ecto.Query

  alias Domain.AdventureReview

  def get(id) do
    Models.Adventure
    |> preload(:creator)
    |> Repository.get(id)
    |> case do
      nil -> {:error, :not_found}
      adventure -> {:ok, adventure |> build_adventure}
    end
  end

  defp build_adventure(adventure_model) do
    %AdventureReview.Adventure{
      id: adventure_model.id,
      creator: build_creator(adventure_model.creator),
      status: adventure_model.status
    }
  end

  defp build_creator(nil), do: nil

  defp build_creator(creator_model) do
    %AdventureReview.Adventure.Creator{
      id: creator_model.id,
      email: creator_model.email,
      name: creator_model.name
    }
  end
end
