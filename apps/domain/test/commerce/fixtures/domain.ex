defmodule Domain.Commerce.Fixtures.Domain do
  alias Domain.Commerce

  def uuid() do
    Ecto.UUID.generate()
  end

  def build_account(params \\ %{}) do
    %Commerce.Transfer.Account{}
    |> struct!(params)
  end

  def build_transaction(params \\ %{}) do
    %Commerce.Transfer.Transaction{}
    |> struct!(params)
  end

  def build_transferable(params \\ %{}) do
    %Commerce.Transfer.Transferable{}
    |> struct!(params)
  end

  def build_account_balance(params \\ %{}) do
    %Commerce.Transfer.Account.Balance{}
    |> struct!(params)
  end
end
