defmodule Domain.Creator.EventHandlers.Adventure do
  use Domain.EventHandler
  use Infrastructure.Repository.Models

  import Ecto.Query

  alias Infrastructure.Repository

  def process(multi, %Domain.Event{aggregate_name: "Creator.Adventure", name: "Created"} = event) do
    event.data
    |> case do
      %{
        name: name,
        creator_id: creator_id
      } ->
        adventure =
          %Models.Adventure{}
          |> Models.Adventure.changeset(%{
            id: event.aggregate_id,
            name: name,
            creator_id: creator_id
          })

        multi
        |> Ecto.Multi.insert({event.id, event.name}, adventure)
    end
  end

  def process(multi, %Domain.Event{aggregate_name: "Creator.Adventure", name: "Changed"} = event) do
    updates =
      event.data
      |> Map.take([
        :description,
        :language,
        :difficulty_level,
        :min_time,
        :max_time,
        :name,
        :show
      ])

    adventure =
      Models.Adventure
      |> Repository.get(event.aggregate_id)
      |> Models.Adventure.changeset(updates)

    multi
    |> Ecto.Multi.update({event.id, event.name}, adventure)
  end

  def process(multi, %Domain.Event{aggregate_name: "Creator.Adventure", name: "PointChanged"} = event) do
    updates =
      event.data
      |> Map.take([
        :position,
        :radius,
        :parent_point_id,
        :show,
        :answers
      ])
      |> Enum.map(fn
        {:position, changeset = %Ecto.Changeset{}} ->
          %{lat: lat, lng: lng} =
            changeset
            |> Ecto.Changeset.apply_changes()

          {:position, %Geo.Point{coordinates: {lat, lng}}}

        {:position, %{lat: lat, lng: lng}} ->
          {:position, %Geo.Point{coordinates: {lat, lng}}}

        {key, value} ->
          {key, value}
      end)
      |> Enum.into(%{})

    point =
      Models.Point
      |> Repository.get(event.data.id)
      |> Models.Point.changeset(updates)

    multi
    |> Ecto.Multi.update({event.id, event.name}, point)
  end

  def process(multi, %Domain.Event{aggregate_name: "Creator.Adventure", name: "PointAdded"} = event) do
    event.data
    |> case do
      %{
        id: id,
        parent_point_id: parent_point_id,
        radius: radius,
        show: show,
        lat: lat,
        lng: lng
      } ->
        point =
          %Models.Point{}
          |> Models.Point.changeset(%{
            id: id,
            show: show,
            radius: radius,
            parent_point_id: parent_point_id,
            adventure_id: event.aggregate_id,
            position: %Geo.Point{coordinates: {lat, lng}}
          })

        multi
        |> Ecto.Multi.insert({event.id, event.name}, point)
    end
  end

  def process(multi, %Domain.Event{aggregate_name: "Creator.Adventure", name: "PointRemoved"} = event) do
    event.data
    |> case do
      %{
        id: point_id
      } ->
        point =
          Models.Point
          |> Repository.get(point_id)

        multi
        |> Ecto.Multi.delete({event.id, event.name}, point)
    end
  end

  def process(multi, %Domain.Event{aggregate_name: "Creator.Adventure", name: "PointClueAdded"} = event) do
    event.data
    |> case do
      %{
        id: id,
        point_id: point_id,
        type: type,
        description: description,
        tip: tip,
        sort: sort
      } ->
        point =
          %Models.Clue{}
          |> Models.Clue.changeset(%{
            id: id,
            point_id: point_id,
            type: type,
            description: description,
            tip: tip,
            sort: sort
          })

        multi
        |> Ecto.Multi.insert({event.id, event.name}, point)
    end
  end

  def process(multi, %Domain.Event{aggregate_name: "Creator.Adventure", name: "PointClueRemoved"} = event) do
    event.data
    |> case do
      %{
        clue_id: clue_id
      } ->
        point =
          Models.Clue
          |> Repository.get(clue_id)

        multi
        |> Ecto.Multi.delete({event.id, event.name}, point)
    end
  end

  def process(multi, %Domain.Event{aggregate_name: "Creator.Adventure", name: "PointClueChanged"} = event) do
    updates =
      event.data
      |> Map.take([
        :point_id,
        :type,
        :description,
        :tip,
        :sort,
        :asset_id
      ])

    clue =
      Models.Clue
      |> Repository.get(event.data.id)
      |> Models.Clue.changeset(updates)

    multi
    |> Ecto.Multi.update({event.id, event.name}, clue)
  end
end
