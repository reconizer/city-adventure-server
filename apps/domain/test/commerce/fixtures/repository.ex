defmodule Domain.Commerce.Fixtures.Repository do
  use Infrastructure.Repository.Models

  alias Ecto.Multi
  alias Infrastructure.Repository

  def commit(multis) when is_list(multis) do
    multis
    |> Enum.map(&commit/1)
  end

  def commit(multi) do
    multi
    |> Repository.transaction()
  end

  def build_user(user_params \\ %{}) do
    Multi.new()
    |> Multi.insert(:user, user(user_params))
    |> Multi.insert(:account, account())
    |> Multi.insert(:user_account, &user_account/1)
  end

  def build_creator(creator_params \\ %{}) do
    Multi.new()
    |> Multi.insert(:creator, creator(creator_params))
    |> Multi.insert(:account, account())
    |> Multi.insert(:creator_account, &creator_account/1)
  end

  def build_shop(shop_params \\ %{}) do
    Multi.new()
    |> Multi.insert(:shop, shop(shop_params))
    |> Multi.insert(:account, account())
    |> Multi.insert(:shop_account, &shop_account/1)
  end

  def build_currency(currency_params \\ %{}) do
    Multi.new()
    |> Multi.insert(:currency, currency(currency_params))
    |> Multi.insert(:transferable, transferable())
    |> Multi.insert(:transferable_currency, &transferable_currency/1)
  end

  def build_product(product_params \\ %{}) do
    Multi.new()
    |> Multi.insert(:product, product(product_params))
    |> Multi.insert(:transferable, transferable())
    |> Multi.insert(:transferable_product, &transferable_product/1)
  end

  def build_adventure(adventure_params \\ %{}) do
    creator_id =
      adventure_params
      |> Map.get(:crator_id, Ecto.UUID.generate())

    adventure_params = Map.put_new(adventure_params, :creator_id, creator_id)

    Multi.new()
    |> Multi.append(build_creator(%{id: creator_id}))
    |> Multi.insert(:adventure, adventure(adventure_params))
    |> Multi.insert(:transferable, transferable())
    |> Multi.insert(:transferable_adventure, &transferable_adventure/1)
  end

  def adventure(params \\ %{}) do
    %Models.Adventure{}
    |> struct(params)
  end

  def creator(params \\ %{}) do
    %Models.Creator{
      name: Faker.Commerce.product_name(),
      email: Faker.Internet.email(),
      password_digest: "testtest"
    }
    |> struct(params)
  end

  def currency(params \\ %{}) do
    %Models.Commerce.Currency{
      name: Faker.Commerce.product_name()
    }
    |> struct(params)
  end

  def transferable(params \\ %{}) do
    %Models.Commerce.Transferable{}
    |> struct(params)
  end

  def transferable_currency(params \\ %{}) do
    %Models.Commerce.TransferableCurrency{}
    |> struct(params)
  end

  def transferable_product(params \\ %{}) do
    %Models.Commerce.TransferableProduct{}
    |> struct(params)
  end

  def transferable_adventure(params \\ %{}) do
    %Models.Commerce.TransferableAdventure{}
    |> struct(params)
  end

  def user(params \\ %{}) do
    %Models.User{
      nick: Faker.Internet.user_name(),
      email: Faker.Internet.free_email(),
      password_digest: Comeonin.Bcrypt.hashpwsalt("1234")
    }
    |> struct(params)
  end

  def product(params \\ %{}) do
    %Models.Commerce.Product{
      name: Faker.Commerce.product_name(),
      google_product_id: Faker.Commerce.product_name_product(),
      apple_product_id: Faker.Commerce.product_name_product()
    }
    |> struct(params)
  end

  def shop(params \\ %{}) do
    %Models.Commerce.Shop{
      type: Faker.Commerce.department()
    }
    |> struct(params)
  end

  def account(params \\ %{}) do
    %Models.Commerce.Account{}
    |> struct(params)
  end

  def user_account(params) do
    %Models.Commerce.UserAccount{}
    |> struct(params)
  end

  def creator_account(params) do
    %Models.Commerce.CreatorAccount{}
    |> struct(params)
  end

  def shop_account(params) do
    %Models.Commerce.ShopAccount{}
    |> struct(params)
  end
end
