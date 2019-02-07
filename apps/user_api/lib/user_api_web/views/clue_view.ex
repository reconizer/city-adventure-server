defmodule UserApiWeb.ClueView do
  use UserApiWeb, :view

  def render("index.json", %{session: %Session{context: %{"clues" => clues}} = _session}) do
    clues
    |> Enum.map(&render_point/1)
  end

  def render("list_for_point.json", %{session: %Session{context: %{"clues" => clues}} = _session}) do
    clues
    |> Enum.map(&render_clues/1)
  end

  defp render_point(point) do
    %{
      point_id: point.id,
      discovery_timestamp: point.user_points |> generate_clue_date(),
      clues: point.clues |> Enum.map(&render_clues/1)
    }
  end

  defp render_clues(%{asset_id: nil} = clue) do
    %{
      id: clue.id,
      type: clue.type,
      description: clue.description,
      original_asset_url: nil,
      conversion_urls: []   
    }
  end

  defp render_clues(%{asset: %{asset_conversions: []} = asset} = clue) do
    %{
      id: clue.id,
      type: clue.type,
      description: clue.description,
      original_asset_url: asset_url(asset),
      conversion_urls: []   
    }
  end

  defp render_clues(%{asset: %{asset_conversions: conversions} = asset} = clue) do
    %{
      id: clue.id,
      type: clue.type,
      description: clue.description,
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