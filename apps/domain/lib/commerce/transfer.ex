defmodule Domain.Commerce.Transfer do
  alias Domain.Commerce.Transfer
  use Ecto.Schema
  use Domain.Event, "Commerce.Transfer"
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    embeds_many(:transactions, Transfer.Transaction)
    embeds_many(:pending_transactions, Transfer.Transaction)
    embeds_many(:accounts, Transfer.Account)
    embeds_many(:events, Domain.Event)
  end

  @fields []
  @required_fields @fields

  @spec changeset(Transfer.t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:items)
  end

  @spec add_account(Transfer.t(), Transfer.Account.t()) :: {:ok, Transfer.t()}
  def add_account(transfer, account) do
    transfer
    |> get_account(account.id)
    |> case do
      :error ->
        {:ok, %{transfer | accounts: transfer.accounts ++ [account]}}

      {:ok, found_account} ->
        accounts = transfer.accounts -- [found_account]
        {:ok, %{transfer | accounts: accounts ++ [account]}}
    end
  end

  @spec add_account!(Transfer.t(), Transfer.Account.t()) :: Transfer.t()
  def add_account!(transfer, account) do
    transfer
    |> add_account(account)
    |> case do
      {:ok, transfer} -> transfer
    end
  end

  @spec get_account(Transfer.t(), Ecto.UUID.t()) :: :error | {:ok, Transfer.Account.t()}
  def get_account(%Transfer{} = transfer, account_id) do
    transfer.accounts
    |> Enum.find(&(&1.id == account_id))
    |> case do
      nil -> :error
      item -> {:ok, item}
    end
  end

  @spec get_account!(Transfer.t(), Ecto.UUID.t()) :: Transfer.Account.t()
  def get_account!(%Transfer{} = transfer, account_id) do
    transfer
    |> get_account(account_id)
    |> case do
      {:ok, item} -> item
    end
  end

  @spec add_transaction(Transfer.t(), Transfer.Transaction.t()) :: {:ok, Transfer.t()}
  def add_transaction(transfer, transaction) do
    transfer
    |> get_transaction(transaction.id)
    |> case do
      :error ->
        transfer =
          %{transfer | transactions: transfer.transactions ++ [transaction]}
          |> emit("TransactionAdded", %{
            id: transaction.id,
            from_account_id: transaction.from_account_id,
            to_account_id: transaction.to_account_id,
            transferable_id: transaction.transferable_id,
            transferable_amount: transaction.transferable_amount,
            created_at: NaiveDateTime.utc_now()
          })

        {:ok, transfer}

      _ ->
        {:ok, transfer}
    end
  end

  @spec add_transaction!(Transfer.t(), Transfer.Transaction.t()) :: Transfer.t()
  def add_transaction!(transfer, transaction) do
    transfer
    |> add_transaction(transaction)
    |> case do
      {:ok, transaction} -> transaction
    end
  end

  @spec get_transaction(Transfer.t(), Ecto.UUID.t()) :: :error | {:ok, Transfer.Transaction.t()}
  def get_transaction(%Transfer{} = transfer, transaction_id) do
    transfer.transactions
    |> Enum.find(&(&1.id == transaction_id))
    |> case do
      nil -> :error
      item -> {:ok, item}
    end
  end

  @spec get_transaction!(Transfer.t(), Ecto.UUID.t()) :: Transfer.Transaction.t()
  def get_transaction!(%Transfer{} = transfer, transaction_id) do
    transfer
    |> get_transaction(transaction_id)
    |> case do
      {:ok, item} -> item
    end
  end

  @spec remove_transaction(Transfer.t(), Ecto.UUID.t()) :: {:ok, Transfer.t()}
  def remove_transaction(transfer, transaction_id) do
    transfer
    |> get_transaction(transaction_id)
    |> case do
      :error ->
        {:ok, transfer}

      {:ok, transaction} ->
        transfer =
          %{transfer | transactions: transfer.transactions -- [transaction]}
          |> emit("TransactionRemoved", %{
            id: transaction.id,
            created_at: NaiveDateTime.utc_now()
          })

        {:ok, transfer}
    end
  end

  @spec remove_transaction!(Transfer.t(), Ecto.UUID.t()) :: Transfer.t()
  def remove_transaction!(transfer, transaction_id) do
    transfer
    |> remove_transaction(transaction_id)
    |> case do
      {:ok, transfer} -> transfer
    end
  end

  @spec add_pending_transaction(Transfer.t(), Transfer.Transaction.t()) :: {:ok, Transfer.t()}
  def add_pending_transaction(transfer, transaction) do
    transfer.pending_transactions
    |> Enum.find(&(&1.id == transaction.id))
    |> case do
      nil -> {:ok, %{transfer | pending_transactions: transfer.pending_transactions ++ [transaction]}}
      _ -> {:ok, transfer}
    end
  end

  @spec add_pending_transaction!(Transfer.t(), Transfer.Transaction.t()) :: Transfer.t()
  def add_pending_transaction!(transfer, transaction) do
    transfer
    |> add_pending_transaction(transaction)
    |> case do
      {:ok, transfer} -> transfer
    end
  end

  @spec get_pending_transaction(Transfer.t(), Ecto.UUID.t()) :: :error | {:ok, Transfer.Transaction.t()}
  def get_pending_transaction(%Transfer{} = transfer, transaction_id) do
    transfer.pending_transactions
    |> Enum.find(&(&1.id == transaction_id))
    |> case do
      nil -> :error
      item -> {:ok, item}
    end
  end

  @spec get_pending_transaction!(Transfer.t(), Ecto.UUID.t()) :: Transfer.Transaction.t()
  def get_pending_transaction!(%Transfer{} = transfer, transaction_id) do
    transfer
    |> get_pending_transaction(transaction_id)
    |> case do
      {:ok, item} -> item
    end
  end

  @spec remove_pending_transaction(Transfer.t(), Ecto.UUID.t()) :: {:ok, Transfer.t()}
  def remove_pending_transaction(transfer, transaction_id) do
    transfer
    |> get_pending_transaction(transaction_id)
    |> case do
      :error -> {:ok, transfer}
      {:ok, transaction} -> {:ok, %{transfer | pending_transactions: transfer.pending_transactions -- [transaction]}}
    end
  end

  @spec remove_pending_transaction!(Transfer.t(), Ecto.UUID.t()) :: Transfer.t()
  def remove_pending_transaction!(transfer, transaction_id) do
    transfer
    |> remove_pending_transaction(transaction_id)
    |> case do
      {:ok, transfer} -> transfer
    end
  end

  @spec commit(Transfer.t()) :: {:ok, Transfer.t()} | {:error, {Transfer.t(), :not_enough_funds, Transfer.Transaction.t()}}
  def commit(transfer) do
    transfer.pending_transactions
    |> Enum.reduce_while({:ok, transfer}, fn pending_transaction, {:ok, transfer} ->
      with from_account <- transfer |> get_account!(pending_transaction.from_account_id),
           to_account <- transfer |> get_account!(pending_transaction.to_account_id) do
        from_account
        |> Transfer.Account.can_transfer?(pending_transaction.transferable_amount, pending_transaction.transferable_id)
        |> case do
          true ->
            from_account = from_account |> Transfer.Account.subtract!(pending_transaction.transferable_amount, pending_transaction.transferable_id)
            to_account = to_account |> Transfer.Account.add!(pending_transaction.transferable_amount, pending_transaction.transferable_id)

            transfer =
              transfer
              |> add_account!(from_account)
              |> add_account!(to_account)
              |> remove_pending_transaction!(pending_transaction.id)
              |> add_transaction!(pending_transaction)

            {:cont, {:ok, transfer}}

          false ->
            {:halt, {:error, {transfer, :not_enough_funds, pending_transaction}}}
        end
      end
    end)
  end

  @spec add_to_transfer(Transfer.t(), Transfer.Account.t(), Transfer.Account.t(), Transfer.Transferable.t(), non_neg_integer()) :: Transfer.t()
  def add_to_transfer(%Transfer{} = transfer, from_account, to_account, transferable, transferable_amount) do
    transaction = %Transfer.Transaction{
      id: Infrastructure.Repository.Models.uuid(),
      from_account_id: from_account.id,
      to_account_id: to_account.id,
      transferable_id: transferable.id,
      transferable_amount: transferable_amount,
      created_at: NaiveDateTime.utc_now()
    }

    transfer
    |> add_account!(from_account)
    |> add_account!(to_account)
    |> add_pending_transaction!(transaction)
  end
end
