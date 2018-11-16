defmodule Infrastructure.Repository.Migrations.CreateAssets do
  use Ecto.Migration

  def change do
    create table(:assets, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string, null: false)
      add(:extension, :string, null: false)
      add(:type, :string, null: false)
      add(:uploaded, :boolean, null: false, default: false)
      timestamps()
    end
  end
end
