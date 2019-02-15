defmodule Domain.AdventureReview.Repository.Message do
  use Infrastructure.Repository.Models
  use Domain.Repository
  alias Infrastructure.Repository
  alias Infrastructure.Repository.Models
  import Ecto.Query

  alias Domain.AdventureReview

  def get_for_adventure(adventure_id) do
  end

  def fetch_author(id, "administrator") do
    Models.Administrator
    |> Repository.get(id)
    |> build_author
  end

  def fetch_author(id, "creator") do
    Models.Creator
    |> Repository.get(id)
    |> build_author
  end

  defp build_author(nil), do: nil

  defp build_author(author_data) do
    %AdventureReview.Message.Author{
      id: author_data.id,
      name: author_data.name,
      email: author_data.email,
      type: author_data.type
    }
  end
end
