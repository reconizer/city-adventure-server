defmodule Domain.Commerce.Transfer.Repository do
  alias Domain.Commerce.Transfer
  alias Infrastructure.Repository, as: Repo
  alias Infrastructure.Repository.Models
  alias Infrastructure.Repository.Models.Commerce
  import Ecto.Query

  # def get(transfer_id) do
  #   fetch_transfer(transfer_id)
  #   |> fetch_accounts()
  # end

  # def fetch_transfer(transfer_id) do
  #   order =
  #     Commerce.Order
  #     |> preload(order_transfers: :transfers)
  #     |> Repo.get(transfer_id)

  #   transfer = build_transfer(order)

  #   order.transfers
  #   |> Enum.map(&build_transfer_item/1)
  #   |> set(transfer, :items)
  # end

  # def fetch_accounts(transfer) do
  #   transfer.items
  #   |> Enum.flat_map(fn item ->
  #     [item.from_account_id, item.to_account_id]
  #   end)
  #   |> Enum.filter(& &1)
  #   |> case do
  #     account_ids ->
  #       Commerce.Account
  #       |> where([account], account.id in ^account_ids)
  #       |> join(:left, [account], transfer in Commerce.Transfer, on: transfer.from_account_id == account.id or transfer.to_account_id == account.id)
  #       |> group_by([account, transfer], [account.id, transfer.transferable_id])
  #       |> select([account, transfer], %{
  #         id: account.id,
  #         transferable_id: transfer.transferable_id,
  #         balance_in: fragment("sum(?) filter (where ? = ?)", transfer.transferable_amount, transfer.to_account_id, account.id),
  #         balance_out: fragment("sum(?) filter (where ? = ?)", transfer.transferable_amount, transfer.from_account_id, account.id)
  #       })
  #       |> Enum.group_by(& &1.account_id, fn account_balance ->
  #         %{
  #           transferable_id: account_balance.transferable_id,
  #           balance: account_balance.balance_in - account_balance.balance_out
  #         }
  #       end)
  #       |> Enum.map(&build_account/1)
  #   end
  #   |> set(transfer, :accounts)
  # end

  # def build_account({account_id, balances}) do
  #   %Transfer.Account{
  #     id: account_id,
  #     balances: balances |> Enum.map(&{&1.transferable_id, &1.balance})
  #   }
  # end

  # def build_transfer(order_model) do
  #   %Transfer{
  #     id: order_model.id
  #   }
  # end

  # def build_transfer_item(transfer_model) do
  #   %Transfer.Item{
  #     id: transfer_model.id,
  #     from_account_id: transfer_model.from_account_id,
  #     to_account_id: transfer_model.to_account_id,
  #     transferable_id: transfer_model.transferable_id,
  #     transferable_amount: transfer_model.transferable_amount,
  #     created_at: transfer_model.inserted_at
  #   }
  # end

  # def set(value, object, key) do
  #   object
  #   |> Map.put(key, value)
  # end
end
