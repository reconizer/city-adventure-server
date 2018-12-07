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

    transaction =
      TestStore.build_transaction(%{
        id: uuid(),
        from_account_id: from_account.id,
        to_account_id: to_account.id,
        transferable_id: currency_transferable.id,
        transferable_amount: 1,
        created_at: NaiveDateTime.utc_now()
      })

    %{
      transfer: %Transfer{},
      from_account: from_account,
      to_account: to_account,
      currency_transferable: currency_transferable,
      item_transferable: item_transferable,
      transaction: transaction
    }
  end

  test "add_account/2", fixtures do
    account = fixtures.from_account
    transfer = fixtures.transfer

    assert {:ok, %{accounts: [account]} = transfer} =
             transfer
             |> Transfer.add_account(account)

    assert {:ok, %{accounts: [account]} = transfer} =
             transfer
             |> Transfer.add_account(account)
  end

  test "add_account!/2", fixtures do
    account = fixtures.from_account
    transfer = fixtures.transfer

    assert (%Transfer{accounts: [account]} = transfer) = transfer |> Transfer.add_account!(account)
    assert (%Transfer{accounts: [account]} = transfer) = transfer |> Transfer.add_account!(account)
  end

  test "get_account/2", fixtures do
    account = fixtures.from_account
    other_account = fixtures.to_account

    transfer = %{fixtures.transfer | accounts: [account]}

    assert {:ok, account} = transfer |> Transfer.get_account(account.id)
    assert :error = transfer |> Transfer.get_account(other_account.id)
  end

  test "get_account!/2", fixtures do
    account = fixtures.from_account
    other_account = fixtures.to_account
    transfer = %{fixtures.transfer | accounts: [account]}

    assert account = transfer |> Transfer.get_account!(account.id)

    assert_raise(CaseClauseError, fn ->
      transfer |> Transfer.get_account!(other_account.id)
    end)
  end

  test "get_transaction/2", fixtures do
    transaction = fixtures.transaction
    transfer = %{fixtures.transfer | transactions: [transaction]}

    assert {:ok, transaction} =
             transfer
             |> Transfer.get_transaction(transaction.id)

    assert :error =
             transfer
             |> Transfer.get_transaction(uuid())
  end

  test "get_transaction!/2", fixtures do
    transaction = fixtures.transaction
    transfer = %{fixtures.transfer | transactions: [transaction]}

    assert transaction =
             transfer
             |> Transfer.get_transaction!(transaction.id)

    assert_raise(CaseClauseError, fn ->
      transfer
      |> Transfer.get_transaction!(uuid())
    end)
  end

  test "add_transaction/2", fixtures do
    transaction = fixtures.transaction
    transfer = fixtures.transfer

    result = transfer |> Transfer.add_transaction(transaction)

    assert {:ok, %{transactions: [transaction], events: [%{name: "TransactionAdded"}]}} = result

    result = transfer |> Transfer.add_transaction(transaction)

    assert {:ok, %{transactions: [transaction], events: [%{name: "TransactionAdded"}]}} = result
  end

  test "add_transaction!/2", fixtures do
    transaction = fixtures.transaction
    transfer = fixtures.transfer

    result = transfer |> Transfer.add_transaction!(transaction)

    assert %{transactions: [transaction], events: [%{name: "TransactionAdded"}]} = result
  end

  test "remove_transaction/2", fixtures do
    transaction = fixtures.transaction
    transfer = %{fixtures.transfer | transactions: [transaction]}

    result = transfer |> Transfer.remove_transaction(transaction.id)

    assert {:ok, %{transactions: [], events: [%{name: "TransactionRemoved"}]}} = result
  end

  test "remove_transaction!/2", fixtures do
    transaction = fixtures.transaction
    transfer = %{fixtures.transfer | transactions: [transaction]}

    result = transfer |> Transfer.remove_transaction!(transaction.id)

    assert %{transactions: [], events: [%{name: "TransactionRemoved"}]} = result
  end

  test "add_pending_transaction/2", fixtures do
    transaction = fixtures.transaction
    transfer = fixtures.transfer

    result = transfer |> Transfer.add_pending_transaction(transaction)

    assert {:ok, %{pending_transactions: [transaction]}} = result
  end

  test "add_pending_transaction!/2", fixtures do
    transaction = fixtures.transaction
    transfer = fixtures.transfer

    result = transfer |> Transfer.add_pending_transaction!(transaction)

    assert %{pending_transactions: [transaction]} = result
  end

  test "get_pending_transaction/2", fixtures do
    transaction = fixtures.transaction
    transfer = %{fixtures.transfer | pending_transactions: [transaction]}

    result = transfer |> Transfer.get_pending_transaction(transaction.id)

    assert {:ok, transaction} = result

    result = transfer |> Transfer.get_pending_transaction(uuid)

    assert :error = result
  end

  test "get_pending_transaction!/2", fixtures do
    transaction = fixtures.transaction
    transfer = %{fixtures.transfer | pending_transactions: [transaction]}

    result = transfer |> Transfer.get_pending_transaction!(transaction.id)

    assert transaction = result

    assert_raise(CaseClauseError, fn ->
      transfer |> Transfer.get_pending_transaction!(uuid())
    end)
  end

  test "remove_pending_transaction/2", fixtures do
    transaction = fixtures.transaction
    transfer = %{fixtures.transfer | pending_transactions: [transaction]}

    result = transfer |> Transfer.remove_pending_transaction(transaction.id)

    assert {:ok, %{pending_transactions: []}} = result
  end

  test "remove_pending_transaction!/2", fixtures do
    transaction = fixtures.transaction
    transfer = %{fixtures.transfer | pending_transactions: [transaction]}

    result = transfer |> Transfer.remove_pending_transaction!(transaction.id)

    assert %{pending_transactions: []} = result
  end

  test "add_to_transfer/5", fixtures do
    transfer = fixtures.transfer
    from_account = fixtures.from_account
    to_account = fixtures.to_account
    currency_transferable = fixtures.currency_transferable

    result =
      transfer
      |> Transfer.add_to_transfer(
        from_account,
        to_account,
        currency_transferable,
        1
      )

    pending_transaction = %{
      from_account_id: from_account.id,
      to_account_id: to_account.id,
      transferable_id: currency_transferable.id,
      transferable_amount: 1
    }

    assert %{
             accounts: [to_account, from_account],
             pending_transactions: [pending_transaction]
           } = result
  end

  test "commit/1", fixtures do
    transfer = fixtures.transfer
    from_account = fixtures.from_account
    to_account = fixtures.to_account
    currency_transferable = fixtures.currency_transferable
    item_transferable = fixtures.item_transferable

    result =
      transfer
      |> Transfer.add_to_transfer(
        from_account,
        to_account,
        currency_transferable,
        10
      )
      |> Transfer.add_to_transfer(
        to_account,
        from_account,
        item_transferable,
        1
      )
      |> Transfer.commit()

    assert {:ok, transfer} = result
    assert transfer.events |> length == 2
    assert transfer.transactions |> length == 2
    assert transfer.pending_transactions |> length == 0
    assert transfer.accounts |> length == 2

    result =
      fixtures.transfer
      |> Transfer.add_to_transfer(
        from_account,
        to_account,
        currency_transferable,
        1
      )
      |> Transfer.add_to_transfer(
        to_account,
        from_account,
        currency_transferable,
        1
      )
      |> Transfer.commit()

    assert {:ok, transfer} = result

    result =
      fixtures.transfer
      |> Transfer.add_to_transfer(
        to_account,
        from_account,
        currency_transferable,
        1
      )
      |> Transfer.add_to_transfer(
        from_account,
        to_account,
        currency_transferable,
        1
      )
      |> Transfer.commit()

    assert {:error, {_, :not_enough_funds, _}} = result
  end
end
