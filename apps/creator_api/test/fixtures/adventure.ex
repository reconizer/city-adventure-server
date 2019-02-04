defmodule CreatorApiWeb.Fixtures.Adventure do
  alias Domain.Creator

  def new(params) do
    Creator.Adventure.new(params)
  end

  def with_point(adventure, point_params) do
    adventure
    |> Creator.Adventure.add_point(point_params)
  end

  def with_clue(adventure, clue_params) do
    adventure
    |> Creator.Adventure.add_clue(clue_params)
  end

  def save(adventure) do
    adventure
    |> Creator.Repository.Adventure.save()
  end

  def get(adventure_id) do
    adventure_id
    |> Creator.Repository.Adventure.get()
  end
end
