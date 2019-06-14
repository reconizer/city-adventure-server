defmodule Domain.CreatorProfile.Repository.Creator do
  use Infrastructure.Repository.Models
  use Domain.Repository
  alias Infrastructure.Repository
  alias Infrastructure.Repository.Models
  import Ecto.Query

  alias Domain.CreatorProfile.{
    Creator,
    Asset
  }

  def get(%{creator_id: id, user_id: user_id}) do
    Models.Creator
    |> join(:left, [creator], asset in assoc(creator, :asset))
    |> join(:left, [creator, asset], creator_follwers in assoc(creator, :creator_followers))
    |> join(:left, [creator, asset, creator_follwers], user_follower in assoc(creator, :creator_followers), on: user_follower.user_id == ^user_id)
    |> select(
      [creator, asset, creator_follwers, user_follower],
      %{
        id: creator.id,
        name: creator.name,
        description: creator.description,
        adventures_count: 0,
        follow: not is_nil(user_follower.user_id),
        followers_count: count(creator_follwers.user_id),
        asset: asset
      }
    )
    |> group_by([creator, asset, creator_follwers, user_follower], [creator.id, asset.id, creator_follwers.creator_id, user_follower.user_id])
    |> Repository.get(id)
    |> case do
      nil ->
        {:error, :not_found}

      user ->
        {:ok, user |> build_creator()}
    end
  end

  def all(%{filter: %{filters: filters, orders: orders} = option, user_id: user_id, position: position}) do
    Models.Creator
    |> join(:left, [creator], asset in assoc(creator, :asset))
    |> join(:left, [creator, asset], creator_follwers in assoc(creator, :creator_followers))
    |> join(:left, [creator, asset, creator_follwers], user_follower in assoc(creator, :creator_followers), on: user_follower.user_id == ^user_id)
    |> join(:left, [creator, asset, creator_follwers, user_follower], adventures in assoc(creator, :adventures), as: :adventures)
    |> select(
      [creator, asset, creator_follwers, user_follower, adventures: adventures],
      %{
        id: creator.id,
        name: creator.name,
        description: creator.description,
        adventures_count: count(adventures.creator_id),
        follow: not is_nil(user_follower.user_id),
        followers_count: count(creator_follwers.user_id),
        asset: asset
      }
    )
    |> filter_name(filters)
    |> filter_range(filters, position)
    |> sort_creator(orders, position)
    |> paginate(option)
    |> group_by([creator, asset, creator_follwers, user_follower, adventures: adventures], [
      creator.id,
      asset.id,
      adventures.creator_id,
      creator_follwers.creator_id,
      user_follower.user_id
    ])
    |> Repository.all()
    |> case do
      nil ->
        {:error, :not_found}

      creators ->
        {:ok, creators |> Enum.map(&build_creator/1)}
    end
  end

  defp build_creator(creator_model) do
    %Creator{
      id: creator_model.id,
      name: creator_model.name,
      follow: creator_model.follow,
      followers_count: creator_model.followers_count,
      adventures_count: creator_model.adventures_count,
      description: creator_model.description,
      asset: creator_model.asset |> build_asset()
    }
  end

  defp build_asset(nil), do: nil

  defp build_asset(asset_model) do
    %Asset{
      id: asset_model.id,
      type: asset_model.type,
      name: asset_model.name,
      extension: asset_model.extension
    }
  end

  defp filter_name(query, %{name: name}) do
    query
    |> where([creator], ilike(creator.name, ^(name <> "%")))
  end

  defp filter_name(query, _), do: query

  defp filter_range(query, %{range: true}, %{lat: lat, lng: lng}) do
    query
    |> join(:inner, [creator, adventures: adventures], start_point in assoc(adventures, :points), on: is_nil(start_point.parent_point_id), as: :start_point)
    |> where(
      [creator, start_point: start_point],
      fragment("st_dwithin(st_setsrid(st_makepoint(?, ?), 4326)::geography, ?::geography, ?)", ^lng, ^lat, start_point.position, 1000)
    )
  end

  defp filter_range(query, _, _), do: query

  defp sort_creator(query, :range, %{lat: lat, lng: lng}) do
    query
    |> has_named_binding?(:start_point)
    |> case do
      true ->
        query
        |> order_by(
          [creator, start_point: start_point],
          fragment("st_distance(st_setsrid(st_makepoint(?, ?), 4326)::geography, ?::geography)", ^lng, ^lat, start_point.position)
        )

      false ->
        query
        |> join(:inner, [creator, adventures: adventures], start_point in assoc(adventures, :points), on: is_nil(start_point.parent_point_id), as: :start_point)
        |> order_by(
          [creator, start_point: start_point],
          fragment("st_distance(st_setsrid(st_makepoint(?, ?), 4326)::geography, ?::geography)", ^lng, ^lat, start_point.position)
        )
    end
  end

  defp sort_creator(query, :rating, _) do
    query
    |> join(:left, [creator, adventures: adventures], adventure_rating in assoc(adventures, :adventure_ratings), as: :adventure_rating)
    |> order_by([creator, adventure_rating: adventure_rating],
      desc:
        fragment(
          "(SUM(DISTINCT ?) / count(distinct ?))",
          adventure_rating.rating,
          adventure_rating.adventure_id
        )
    )
  end

  defp sort_creator(query, _, _) do
    query
    |> order_by(
      [creator, adventure, start_point: start_point],
      asc: creator.name
    )
  end
end
