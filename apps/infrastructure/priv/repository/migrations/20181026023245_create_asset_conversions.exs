defmodule Infrastructure.Repository.Migrations.CreateAssetConversions do
  use Ecto.Migration

  def change do
    create table(:asset_conversions, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:finished, :boolean, null: false, default: false)
      add(:sent, :boolean, null: false, default: false)

      add(:name, :string, null: false)

      add(:asset_id, references(:assets, type: :binary_id, on_delete: :delete_all))

      timestamps()
    end

    create(index(:asset_conversions, [:asset_id]))
  end
end
