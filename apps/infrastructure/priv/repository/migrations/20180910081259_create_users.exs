defmodule Infrastructure.Repository.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :nick, :text
      add :email, :text, null: false 
      add :password_digest, :text, null: false
      timestamps()
    end

  end
end
