defmodule Infrastructure.Repository.Migrations.AddAssetIdToAdventures do
  use Ecto.Migration

  def change do
    alter table(:adventures) do
      add :asset_id, references(:assets, [type: :uuid])
    end
  end
end
