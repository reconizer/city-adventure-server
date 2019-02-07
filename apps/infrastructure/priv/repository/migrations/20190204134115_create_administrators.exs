defmodule Infrastructure.Repository.Migrations.CreateAdministrators do
  use Ecto.Migration

  def change do
    create table(:administrators, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :text, null: false)
      add(:email, :text, null: false)
      add(:password_digest, :text, null: false)
      timestamps()
    end

    create(index(:administrators, [:email], unique: true))
  end
end
