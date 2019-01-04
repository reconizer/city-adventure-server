defmodule Infrastructure.Repository.Migrations.AddAssetIdToImages do
  use Ecto.Migration

  def change do
    alter table(:images) do
      add :asset_id, references(:assets, [type: :uuid])
    end
  end
end
