defmodule Domain.Commerce.Fixtures.Repository.Order do
  #  use ExMachina.Ecto, repo: Infrastructure.Repository
  use Infrastructure.Repository.Models

  import Ecto.Query
  alias Ecto.Multi
  alias Infrastructure.Repository

  def build(order_params \\ %{}) do
    Multi.new()
    |> Multi.insert(:order, order(order_params))
  end

  def with_transfer(multi, transfer_params) do
    multi
    |> Multi.insert(:transfer, transfer(transfer_params))
    |> Multi.run(:order_transfer, fn _repo, %{order: order, transfer: transfer} ->
      Multi.new()
      |> Multi.insert(:order_transfer, order_transfer(%{order_id: order.id, transfer_id: transfer.id}))
      |> Repository.transaction()
    end)
  end

  def order(params \\ %{}) do
    %Models.Commerce.Order{}
    |> struct(params)
  end

  def order_transfer(params \\ %{}) do
    %Models.Commerce.OrderTransfer{}
    |> struct(params)
  end

  def transfer(params \\ %{}) do
    %Models.Commerce.Transfer{}
    |> struct(params)
  end
end
