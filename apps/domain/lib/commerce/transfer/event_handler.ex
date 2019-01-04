defmodule Domain.Commerce.Transfer.EventHandler do
  use Domain.EventHandler
  alias Infrastructure.Repository
  alias Infrastructure.Repository.Models.Commerce, as: CommerceModels

  def process(multi, %Domain.Event{aggregate_name: "Transfer", name: "TransactionAdded"} = event) do
    event.data
    |> case do
      %{
        id: id,
        from_account_id: from_account_id,
        to_account_id: to_account_id,
        transferable_id: transferable_id,
        transferable_amount: transferable_amount,
        created_at: created_at
      } ->
        transaction =
          %CommerceModels.Transfer{}
          |> CommerceModels.Transfer.changeset(%{
            id: id,
            from_account_id: from_account_id,
            to_account_id: to_account_id,
            transferable_id: transferable_id,
            transferable_amount: transferable_amount,
            created_at: created_at
          })

        multi
        |> Ecto.Multi.insert({event.id, id}, transaction)

      _ ->
        multi
    end
  end

  def process(multi, %Domain.Event{aggregate_name: "Transfer", name: "TransactionRemoved"} = event) do
    event.data
    |> case do
      %{
        id: id
      } ->
        transaction =
          CommerceModels.Transfer
          |> Repository.get(id)

        multi
        |> Ecto.Multi.delete({event.id, id}, transaction)

      _ ->
        multi
    end
  end
end
