defmodule Infrastructure.Api.Google.Product do
  use Ecto.Schema
  import Ecto.Changeset
  # %{
  #   "kind" => kind,
  #   "purchaseTimeMillis" => purchase_time_millis,
  #   "purchaseState" => purchase_state,
  #   "consumptionState" => consumption_state,
  #   "developerPayload" => developer_payload,
  #   "orderId" => order_id,
  #   "purchaseType" => purchase_type
  # }
  @primary_key false
  embedded_schema do
    field(:kind)
    field(:purchase_time_millis)
    field(:purchase_state)
    field(:consumption_state)
    field(:developer_payload)
    field(:order_id)
    field(:purchase_type)
  end

  @fields ~w(kind purchase_time_millis purchase_state consumption_state developer_payload order_id purchase_type)a
  @required_fields @fields

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end

  def build(params) do
    %__MODULE__{}
    |> changeset(params)
  end
end
