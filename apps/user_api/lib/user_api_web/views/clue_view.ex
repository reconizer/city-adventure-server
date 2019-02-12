defmodule UserApiWeb.ClueView do
  use UserApiWeb, :view

  def render("index.json", %{session: %Session{context: %{"points" => points, "user_points" => user_points}} = _session}) do
    points
    |> Enum.map(fn point ->
      point
      |> render_point(user_points)
    end)
  end

  def render("list_for_point.json", %{session: %Session{context: %{"clues" => clues}} = _session}) do
    clues
    |> Enum.map(&render_clues/1)
  end

  defp render_point(point, user_points) do
    %{
      point_id: point.id,
      discovery_timestamp: user_points |> find_user_point(point) |> generate_clue_date(),
      clues: point.clues |> Enum.map(&render_clues/1)
    }
  end

  defp render_clues(%{type: "url"} = clue) do
    %{
      id: clue.id,
      type: clue.type,
      description: clue.description,
      original_asset_url: clue.url,
      conversion_urls: []
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

  def find_user_point(user_points, point) do
    user_points
    |> Enum.find(fn user_point ->
      user_point.point_id == point.id
    end)
  end

  defp generate_clue_date(user_point) do
    user_point
    |> Map.get(:inserted_at)
    |> Timex.to_unix()
  end
end
