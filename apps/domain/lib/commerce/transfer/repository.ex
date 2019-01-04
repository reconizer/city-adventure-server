defmodule Domain.Commerce.Transfer.Repository do
  use Domain.Repository

  alias Domain.Commerce.Transfer
  alias Infrastructure.Repository, as: Repo
  alias Infrastructure.Repository.Models
  alias Infrastructure.Repository.Models.Commerce
  import Ecto.Query

  @spec get(any()) :: Domain.Commerce.Transfer.t()
  def get(transfer_id) do
    order =
      Commerce.Order
      |> preload(:transfers)
      |> Repo.get(transfer_id)

    transfer =
      order
      |> build_transfer

    account_ids =
      order.transfers
      |> Enum.flat_map(fn transfer ->
        [transfer.from_account_id, transfer.to_account_id]
      end)
      |> Enum.uniq()

    accounts = fetch_accounts(account_ids)

    transactions =
      order.transfers
      |> Enum.map(fn transaction ->
        %Transfer.Transaction{
          from_account_id: transaction.from_account_id,
          to_account_id: transaction.to_account_id,
          transferable_id: transaction.transferable_id,
          transferable_amount: transaction.transferable_amount
        }
      end)

    %{transfer | accounts: accounts, transactions: transactions}
  end

  def fetch_accounts(account_ids) do
    Commerce.Account
    |> where([account], account.id in ^account_ids)
    |> join(:left, [account], transfer in Commerce.Transfer, on: transfer.from_account_id == account.id or transfer.to_account_id == account.id)
    |> group_by([account, transfer], [account.id, transfer.transferable_id])
    |> select([account, transfer], %{
      id: account.id,
      transferable_id: transfer.transferable_id,
      balance_in: fragment("coalesce(sum(coalesce(?, 0)) filter (where ? = ?), 0)", transfer.transferable_amount, transfer.to_account_id, account.id),
      balance_out: fragment("coalesce(sum(coalesce(?, 0)) filter (where ? = ?), 0)", transfer.transferable_amount, transfer.from_account_id, account.id)
    })
    |> Repo.all()
    |> Enum.group_by(& &1.id, fn account_balance ->
      {
        account_balance.transferable_id,
        account_balance.balance_in - account_balance.balance_out
      }
    end)
    |> Enum.map(fn {account_id, account_balances} ->
      account_balances
      |> Enum.reduce(%Transfer.Account{id: account_id}, fn {transferable_id, balance}, account ->
        account |> Transfer.Account.add!(balance, transferable_id)
      end)
    end)
  end

  def build_transfer(order_model) do
    %Transfer{
      id: order_model.id
    }
  end
end
