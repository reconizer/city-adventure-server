defmodule Infrastructure.Repository.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:aggregate_id, :binary_id, null: false)
      add(:aggregate_name, :string, null: false)
      add(:name, :string, null: false)
      add(:data, :map, null: false)
      add(:created_at, :naive_datetime, null: false)
    end
  end
end
