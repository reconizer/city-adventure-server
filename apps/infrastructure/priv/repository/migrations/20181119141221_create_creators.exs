defmodule Infrastructure.Repository.Migrations.CreateCreators do
  use Ecto.Migration

  def change do
    create table(:creators, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :text, null: false
      add :description, :text
      add :address1, :text
      add :address2, :text
      add :city, :text
      add :country, :text
      add :zip_code, :text 
      add :email, :text, null: false 
      add :password_digest, :text, null: false
      timestamps()
    end
  end
end
