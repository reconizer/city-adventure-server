defmodule Domain.Commerce.Transfer.Account do
  alias Domain.Commerce.Transfer
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    embeds_many(:balances, Transfer.Account.Balance)
  end

  @fields []
  @required_fields @fields

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> cast_assoc(:balances)
    |> validate_required(@required_fields)
  end

  def can_transfer?(account, amount, transferable_id) do
    account
    |> get_balance(transferable_id)
    |> case do
      {:ok, %{amount: balance_amount}} when balance_amount >= amount -> true
      _ -> false
    end
  end

  def subtract(account, amount, transferable_id) do
    account
    |> can_transfer?(amount, transferable_id)
    |> case do
      true ->
        balance =
          account
          |> get_balance!(transferable_id)

        balances = account.balances -- [balance]
        balance = %{balance | amount: balance.amount - amount}

        {:ok, %{account | balances: [balance | balances]}}

      false ->
        {:error, {:not_enough_funds, account}}
    end
  end

  def subtract!(account, amount, transferable_id) do
    account
    |> subtract(amount, transferable_id)
    |> case do
      {:ok, account} -> account
    end
  end

  def add(account, amount, transferable_id) do
    account
    |> get_balance(transferable_id)
    |> case do
      :error ->
        balance = %Transfer.Account.Balance{transferable_id: transferable_id, amount: amount}
        {:ok, %{account | balances: [balance | account.balances]}}

      {:ok, balance} ->
        balances = account.balances -- [balance]
        balance = %{balance | amount: balance.amount + amount}

        {:ok, %{account | balances: [balance | balances]}}
    end
  end

  def add!(account, amount, transferable_id) do
    account
    |> add(amount, transferable_id)
    |> case do
      {:ok, account} -> account
    end
  end

  def get_balance(account, transferable_id) do
    account.balances
    |> Enum.find(&(&1.transferable_id == transferable_id))
    |> case do
      nil -> :error
      balance -> {:ok, balance}
    end
  end

  def get_balance!(account, transferable_id) do
    account
    |> get_balance(transferable_id)
    |> case do
      {:ok, balance} -> balance
    end
  end
end
