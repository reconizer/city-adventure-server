defmodule Domain do
  def test do
    alias Domain.Creator.Repository.Adventure, as: AdventureRepository
    alias Domain.Creator.Adventure, as: Adventure

    adventure = AdventureRepository.get!("a632e3af-3db7-4229-83cc-6d905eba490f")

    adventure
    |> Adventure.reorder_clues([
      %{id: "2dbe3374-f746-4633-8d89-d816f254a471", point_id: "bbdec0c4-1371-44df-a9ad-49a33407e226"},
      %{id: "afea1529-750c-4076-9542-5548531a4209", point_id: "bbdec0c4-1371-44df-a9ad-49a33407e226"}
    ])
  end
end
