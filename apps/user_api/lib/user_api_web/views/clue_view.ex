defmodule UserApiWeb.ClueView do
  use UserApiWeb, :view

  def render("index.json", %{session: %Session{context: %{"clues" => clues}} = _session}) do
    clues
    |> Enum.map(&render_clues/1)
  end

  defp render_clues(%{point: %{user_points: user_points}, asset_id: nil} = clue) do
    %{
      id: clue.id,
      type: clue.type,
      discovery_timestamp: user_points |> generate_clue_date(),
      description: clue.description,
      point_id: clue.point_id,
      original_asset_url: nil,
      conversion_urls: []   
    }
  end

  defp render_clues(%{point: %{user_points: user_points}, asset: %{asset_conversions: []} = asset} = clue) do
    %{
      id: clue.id,
      type: clue.type,
      discovery_timestamp: user_points |> generate_clue_date(),
      description: clue.description,
      point_id: clue.point_id,
      original_asset_url: asset_url(asset),
      conversion_urls: []   
    }
  end

  defp render_clues(%{point: %{user_points: user_points}, asset: %{asset_conversions: conversions} = asset} = clue) do
    %{
      id: clue.id,
      type: clue.type,
      discovery_timestamp: user_points |> generate_clue_date(),
      description: clue.description,
      point_id: clue.point_id,
      original_asset_url: asset_url(asset),
      conversion_urls: conversions |> Enum.map(&generate_conversion/1)
    }
  end

  defp generate_conversion(conversion) do
    %{
      name: conversion.name,
      url: asset_url(conversion)
    }
  end

  defp generate_clue_date(user_points) do
    user_points
    |> List.first()
    |> Map.get(:inserted_at)
    |> Timex.to_unix()
  end

end