defmodule Infrastructure.Repository.Migrations.CreateTransactionsSchema do
  use Ecto.Migration

  @transactions [
    :create_transferables,
    :create_currencies,
    :create_accounts,
    :create_shops,
    :create_products,
    :create_transferable_currencies,
    :create_transferable_adventures,
    :create_user_accounts,
    :create_shop_accounts,
    :create_creator_accounts,
    :create_transferable_products,
    :create_transfers,
    :create_orders,
    :create_order_transfers
  ]

  def up do
    execute("CREATE SCHEMA IF NOT EXISTS \"commerce\"")
    flush()

    @transactions
    |> Enum.map(fn transaction ->
      apply(__MODULE__, transaction, [direction()])
    end)
  end

  def down do
    @transactions
    |> Enum.reverse()
    |> Enum.map(fn transaction ->
      apply(__MODULE__, transaction, [direction()])
    end)
  end

  def create_transferables(:up) do
    create table(:transferables, prefix: :commerce, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      timestamps()
    end
  end

  def create_transferables(:down) do
    drop(table(:transferables, prefix: :commerce))
  end

  def create_currencies(:up) do
    create table(:currencies, prefix: :commerce, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string, null: false)
      timestamps()
    end
  end

  def create_currencies(:down) do
    drop(table(:currencies, prefix: :commerce))
  end

  def create_accounts(:up) do
    create table(:accounts, prefix: :commerce, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      timestamps()
    end
  end

  def create_accounts(:down) do
    drop(table(:accounts, prefix: :commerce))
  end

  def create_shops(:up) do
    create table(:shops, prefix: :commerce, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:type, :text, null: false)
      timestamps()
    end
  end

  def create_shops(:down) do
    drop(table(:shops, prefix: :commerce))
  end

  def create_products(:up) do
    create table(:products, prefix: :commerce, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :text, null: false)
      add(:google_product_id, :text, null: false)
      add(:apple_product_id, :text, null: false)

      timestamps()
    end
  end

  def create_products(:down) do
    drop(table(:products, prefix: :commerce))
  end

  def create_transferable_currencies(:up) do
    create table(:transferable_currencies, prefix: :commerce, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:currency_id, references(:currencies, type: :uuid), null: false)
      add(:transferable_id, references(:transferables, type: :uuid), null: false)

      timestamps()
    end

    create(index(:transferable_currencies, [:currency_id], prefix: :commerce))
    create(index(:transferable_currencies, [:transferable_id], prefix: :commerce))
    create(index(:transferable_currencies, [:currency_id, :transferable_id], prefix: :commerce))
  end

  def create_transferable_currencies(:down) do
    drop(table(:transferable_currencies, prefix: :commerce))
  end

  def create_transferable_adventures(:up) do
    create table(:transferable_adventures, prefix: :commerce, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:adventure_id, :uuid, null: false)
      add(:transferable_id, references(:transferables, type: :uuid), null: false)

      timestamps()
    end

    create(index(:transferable_adventures, [:transferable_id], prefix: :commerce))
    create(index(:transferable_adventures, [:adventure_id], prefix: :commerce))
    create(index(:transferable_adventures, [:adventure_id, :transferable_id], prefix: :commerce))

    flush()

    execute(
      "ALTER TABLE commerce.transferable_adventures ADD CONSTRAINT transferable_adventures_adventure_id_fkey FOREIGN KEY (adventure_id) REFERENCES adventures(id)"
    )
  end

  def create_transferable_adventures(:down) do
    drop(table(:transferable_adventures, prefix: :commerce))
  end

  def create_user_accounts(:up) do
    create table(:user_accounts, prefix: :commerce, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:user_id, :uuid, null: false)
      add(:account_id, references(:accounts, type: :uuid), null: false)

      timestamps()
    end

    create(index(:user_accounts, [:user_id], prefix: :commerce))
    create(index(:user_accounts, [:account_id], prefix: :commerce))
    create(index(:user_accounts, [:user_id, :account_id], prefix: :commerce))

    flush()

    execute("ALTER TABLE commerce.user_accounts ADD CONSTRAINT user_accounts_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id)")
  end

  def create_user_accounts(:down) do
    drop(table(:user_accounts, prefix: :commerce))
  end

  def create_creator_accounts(:up) do
    create table(:creator_accounts, prefix: :commerce, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:creator_id, :uuid, null: false)
      add(:account_id, references(:accounts, type: :uuid), null: false)

      timestamps()
    end

    create(index(:creator_accounts, [:creator_id], prefix: :commerce))
    create(index(:creator_accounts, [:account_id], prefix: :commerce))
    create(index(:creator_accounts, [:creator_id, :account_id], prefix: :commerce))

    flush()

    execute("ALTER TABLE commerce.creator_accounts ADD CONSTRAINT creator_accounts_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES creators(id)")
  end

  def create_creator_accounts(:down) do
    drop(table(:creator_accounts, prefix: :commerce))
  end

  def create_shop_accounts(:up) do
    create table(:shop_accounts, prefix: :commerce, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:shop_id, references(:shops, type: :uuid), null: false)
      add(:account_id, references(:accounts, type: :uuid), null: false)
      timestamps()
    end

    create(index(:shop_accounts, [:shop_id], prefix: :commerce))
    create(index(:shop_accounts, [:account_id], prefix: :commerce))
    create(index(:shop_accounts, [:shop_id, :account_id], prefix: :commerce))
  end

  def create_shop_accounts(:down) do
    drop(table(:shop_accounts, prefix: :commerce))
  end

  def create_transferable_products(:up) do
    create table(:transferable_products, prefix: :commerce, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(:transferable_id, references(:transferables, type: :uuid), null: false)
      add(:product_id, references(:products, type: :uuid), null: false)
      timestamps()
    end

    create(index(:transferable_products, [:transferable_id], prefix: :commerce))
    create(index(:transferable_products, [:product_id], prefix: :commerce))
    create(index(:transferable_products, [:transferable_id, :product_id], prefix: :commerce))
  end

  def create_transferable_products(:down) do
    drop(table(:transferable_products, prefix: :commerce))
  end

  def create_transfers(:up) do
    create table(:transfers, prefix: :commerce, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:from_account_id, references(:accounts, type: :uuid), null: false)
      add(:to_account_id, references(:accounts, type: :uuid), null: false)
      add(:transferable_id, references(:transferables, type: :uuid), null: false)
      add(:transferable_amount, :integer, null: false)
      timestamps()
    end

    create(index(:transfers, [:from_account_id], prefix: :commerce))
    create(index(:transfers, [:to_account_id], prefix: :commerce))
    create(index(:transfers, [:transferable_id], prefix: :commerce))

    create(index(:transfers, [:from_account_id, :to_account_id, :transferable_id], prefix: :commerce))
  end

  def create_transfers(:down) do
    drop(table(:transfers, prefix: :commerce))
  end

  def create_orders(:up) do
    create table(:orders, prefix: :commerce, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      timestamps()
    end
  end

  def create_orders(:down) do
    drop(table(:orders, prefix: :commerce))
  end

  def create_order_transfers(:up) do
    create table(:order_transfers, prefix: :commerce, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:order_id, references(:orders, type: :uuid), null: false)
      add(:transfer_id, references(:transfers, type: :uuid), null: false)
      timestamps()
    end

    create(index(:order_transfers, [:order_id], prefix: :commerce))
    create(index(:order_transfers, [:transfer_id], prefix: :commerce))

    create(index(:order_transfers, [:order_id, :transfer_id], prefix: :commerce))
  end

  def create_order_transfers(:down) do
    drop(table(:order_transfers, prefix: :commerce))
  end
end
