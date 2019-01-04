defmodule Domain.Commerce.TransferRepositoryTest do
  use ExUnit.Case
  alias Domain.Commerce.Transfer

  alias Domain.Commerce.Fixtures.Domain, as: TestStore
  alias Domain.Commerce.Transfer.Repository, as: TransferRepository
  alias Domain.Commerce.Fixtures.Repository, as: TestRepository
  import Domain.Commerce.Fixtures.Domain, only: [uuid: 0]

  setup do
    {:ok, user_data} = TestRepository.build_user() |> TestRepository.commit()

    {:ok, creator_data} = TestRepository.build_creator() |> TestRepository.commit()

    {:ok, currency_data} = TestRepository.build_currency() |> TestRepository.commit()

    {:ok, adventure_data} = TestRepository.build_adventure(%{creator_id: creator_data.creator.id}) |> TestRepository.commit()

    {:ok, %{transferable: currency_transferable}} =
      TestRepository.build_currency(%{
        id: uuid()
      })
      |> TestRepository.commit()

    {:ok, %{transferable: item_transferable}} =
      TestRepository.build_product(%{
        id: uuid()
      })
      |> TestRepository.commit()

    {:ok, %{account: from_account}} =
      TestRepository.build_user(%{
        id: uuid()
      })
      |> TestRepository.commit()

    {:ok, %{account: to_account}} =
      TestRepository.build_user(%{
        id: uuid()
      })
      |> TestRepository.commit()

    {:ok, order_data} =
      TestRepository.Order.build()
      |> TestRepository.Order.with_transfer(%{
        from_account_id: creator_data.account.id,
        to_account_id: user_data.account.id,
        transferable_id: adventure_data.transferable.id,
        transferable_amount: 1
      })
      |> TestRepository.commit()

    %{
      order_id: order_data.order.id,
      transaction:
        TestStore.build_transaction(%{
          id: uuid(),
          from_account_id: from_account.id,
          to_account_id: to_account.id,
          transferable_id: currency_transferable.id,
          transferable_amount: 1,
          created_at: NaiveDateTime.utc_now()
        })
    }
  end

  test "test", fixtures do
    TransferRepository.get(fixtures.order_id)
    |> Transfer.add_transaction!(fixtures.transaction)
    |> TransferRepository.save()
  end
end
