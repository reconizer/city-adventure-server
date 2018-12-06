defmodule Domain.Commerce.TransferTest do
  use ExUnit.Case, async: true

  alias Domain.Commerce.Transfer
  alias Domain.Commerce.Fixtures.Domain, as: TestStore
  import Domain.Commerce.Fixtures.Domain, only: [uuid: 0]

  setup do
    currency_transferable =
      TestStore.build_transferable(%{
        id: uuid()
      })

    item_transferable =
      TestStore.build_transferable(%{
        id: uuid()
      })

    from_account =
      TestStore.build_account(%{
        id: uuid(),
        balances: [
          TestStore.build_account_balance(%{transferable_id: currency_transferable.id, amount: 10})
        ]
      })

    to_account =
      TestStore.build_account(%{
        id: uuid(),
        balances: [
          TestStore.build_account_balance(%{transferable_id: item_transferable.id, amount: 1})
        ]
      })

    %{
      from_account: from_account,
      to_account: to_account,
      currency_transferable: currency_transferable,
      item_transferable: item_transferable
    }
  end

  test "test creating transactions", fixtures do
    transfer = %Transfer{}

    transfer
    |> Transfer.add_to_transfer(fixtures.from_account, fixtures.to_account, fixtures.currency_transferable, 1)
    |> IO.inspect()
    |> Transfer.commit()
    |> IO.inspect()
  end
end
