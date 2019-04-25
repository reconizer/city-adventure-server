defmodule Domain.Creator.EventHandlers.Adventure do
  use Domain.EventHandler
  use Infrastructure.Repository.Models

  import Ecto.Query

  alias Infrastructure.Repository

  def process(multi, %Domain.Event{aggregate_name: "Creator.Adventure", name: "SentToReview"} = event) do
    adventure =
      Models.Adventure
      |> Repository.get(event.aggregate_id)
      |> Models.Adventure.changeset(%{status: "in_review"})

    multi
    |> Ecto.Multi.update({event.id, event.name}, adventure)
  end

  def process(multi, %Domain.Event{aggregate_name: "Creator.Adventure", name: "SentToPending"} = event) do
    adventure =
      Models.Adventure
      |> Repository.get(event.aggregate_id)
      |> Models.Adventure.changeset(%{status: "pending"})

    multi
    |> Ecto.Multi.update({event.id, event.name}, adventure)
  end

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
        :time_answer,
        :password_answer
      ])
      |> Enum.map(fn
        {:position, %{lat: lat, lng: lng}} ->
          {:position, %Geo.Point{coordinates: {lng, lat}}}

        {key, value} ->
          {key, value}
      end)
      |> Enum.into(%{})

    point =
      Models.Point
      |> Repository.get(event.data.id)
      |> Models.Point.changeset(updates)

    multi
    |> update_time_answer(updates, event.data.id)
    |> update_password_answer(updates, event.data.id)
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
            position: %Geo.Point{coordinates: {lng, lat}}
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
        sort: sort,
        url: url
      } ->
        point =
          %Models.Clue{}
          |> Models.Clue.changeset(%{
            id: id,
            point_id: point_id,
            type: type,
            description: description,
            tip: tip,
            sort: sort,
            url: url
          })

        multi
        |> Ecto.Multi.insert({event.id, event.name}, point)
    end
  end

  def process(multi, %Domain.Event{aggregate_name: "Creator.Adventure", name: "ClueAssetAdded"} = event) do
    event.data
    |> case do
      %{
        id: id,
        type: type,
        extension: extension,
        name: name
      } ->
        asset =
          %Models.Asset{}
          |> Models.Asset.changeset(%{
            id: id,
            type: type,
            extension: extension,
            name: name
          })

        multi
        |> Ecto.Multi.insert({event.id, event.name}, asset)
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
        :asset_id,
        :url
      ])

    clue =
      Models.Clue
      |> Repository.get(event.data.id)
      |> Models.Clue.changeset(updates)

    multi
    |> Ecto.Multi.update({event.id, event.name}, clue)
  end

  defp update_password_answer(multi, updates, point_id) do
    updates
    |> case do
      %{password_answer: password_answer} -> password_answer
      %{} -> :not_exists
    end
    |> case do
      nil ->
        answer =
          Models.Answer
          |> where([answer], answer.type == "password")
          |> Repository.get_by(point_id: point_id)

        multi
        |> Ecto.Multi.delete({Ecto.UUID.generate(), "Delete password answer"}, answer)

      :not_exists ->
        multi

      password_answer ->
        Models.Answer
        |> where([answer], answer.type == "password")
        |> Repository.get_by(point_id: point_id)
        |> case do
          nil ->
            answer =
              %Models.Answer{}
              |> Models.Answer.changeset(%{
                point_id: point_id,
                type: "password",
                details: %{
                  password_type: password_answer.type,
                  password: password_answer.password
                }
              })

            multi
            |> Ecto.Multi.insert({Ecto.UUID.generate(), "Add password answer"}, answer)

          answer ->
            answer =
              answer
              |> Models.Answer.changeset(%{
                details: %{
                  password_type: password_answer.type,
                  password: password_answer.password
                }
              })

            multi
            |> Ecto.Multi.update({Ecto.UUID.generate(), "Update password answer"}, answer)
        end
    end
  end

  defp update_time_answer(multi, updates, point_id) do
    updates
    |> case do
      %{time_answer: time_answer} -> time_answer
      %{} -> :not_exists
    end
    |> case do
      nil ->
        answer =
          Models.Answer
          |> where([answer], answer.type == "time")
          |> Repository.get_by(point_id: point_id)

        multi
        |> Ecto.Multi.delete({Ecto.UUID.generate(), "Delete password answer"}, answer)

      :not_exists ->
        multi

      time_answer ->
        Models.Answer
        |> where([answer], answer.type == "time")
        |> Repository.get_by(point_id: point_id)
        |> case do
          nil ->
            answer =
              %Models.Answer{}
              |> Models.Answer.changeset(%{
                point_id: point_id,
                type: "time",
                details: %{
                  start_time: time_answer.start_time,
                  duration: time_answer.duration
                }
              })

            multi
            |> Ecto.Multi.insert({Ecto.UUID.generate(), "Add password answer"}, answer)

          answer ->
            answer =
              answer
              |> Models.Answer.changeset(%{
                details: %{
                  start_time: time_answer.start_time,
                  duration: time_answer.duration
                }
              })

            multi
            |> Ecto.Multi.update({Ecto.UUID.generate(), "Update password answer"}, answer)
        end
    end
  end
end
