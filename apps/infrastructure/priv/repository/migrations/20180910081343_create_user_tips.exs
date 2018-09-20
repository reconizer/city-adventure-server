defmodule Infrastructure.Repository.Migrations.CreateUserTips do
  use Ecto.Migration

  def change do
    create table(:user_tips, primary_key: false) do
      add :clue_id, references(:clues, [type: :uuid]), null: false
      add :user_id, references(:users, [type: :uuid]), null: false
      timestamps()
    end
  end
end
