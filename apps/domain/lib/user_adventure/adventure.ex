defmodule Domain.UserAdventure.Adventure do
  alias Domain.UserAdventure.{
    Adventure,
    Point,
    UserAdventure,
    UserPoint
  }

  use Ecto.Schema
  use Domain.Event, "UserAdventure"
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:current_point_id, Ecto.UUID)
    field(:completed, :boolean, default: false)
    embeds_many(:points, Point)
    embeds_many(:user_points, UserPoint)
    embeds_one(:user_adventure, UserAdventure)

    aggregate_fields()
  end

  @fields [:name, :description, :min_time, :max_time, :difficulty_level, :language, :id]
  @required_fields @fields

  @spec changeset(Adventure.t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:points)
  end

  def resolve_point(adventure, params, user, point) do
    adventure
    |> set_current_point_id(point)
    |> set_answer_type_and_last_point()
    |> add_user_point(params, user, point)
    |> completed_adventure()
    |> create_ranking()
  end

  def check_point_position(%Adventure{} = adventure, %{position: %{coordinates: {lng, lat}}}) do
    adventure
    |> Map.get(:points)
    |> Enum.find(fn %{radius: radius, position: %{coordinates: {p_lng, p_lat}}} = point -> 
      Geocalc.within?(radius, %{lat: p_lat, lng: p_lng}, %{lat: lat, lng: lng})
    end)
    |> case do
      nil -> {:error, {:point, "not_found"}}
      result -> {:ok, result}
    end
  end

  def check_adventure_completed(%Adventure{} = adventure) do
    adventure
    |> Map.get(:completed)
    |> case do
      false -> {:ok, adventure}
      true -> {:error, {:adventure, "alredy completed"}}
    end
  end

  def check_point_completed(%Adventure{} = adventure, %{id: point_id}) do
    adventure
    |> Map.get(:user_points)
    |> Enum.find(fn user_point ->
      user_point.point_id == point_id
    end)
    |> case do
      nil ->
        {:ok, adventure}

      result ->
        result
        |> Map.get(:completed)
        |> case do
          true -> {:error, {:point, "alredy completed"}}
          false -> {:ok, adventure}
        end
    end
  end

  def check_answer_and_time(%Adventure{} = adventure, %{id: point_id}) do
    adventure
    |> get_answers(point_id)
    |> Enum.filter(fn answer ->
      answer.type == "time"
    end)
    |> List.first()
    |> case do
      nil ->
        {:ok, true}

      %{details: %{"starting_time" => starting_time, "duration" => duration}} ->
        time_now = Time.utc_now() |> Time.to_erl() |> :calendar.time_to_seconds()

        cond do
          starting_time <= time_now and time_now <= starting_time + duration ->
            {:ok, true}

          false ->
            {:error, :wrong_time}
        end
    end
  end

  defp set_answer_type_and_last_point(%Adventure{} = adventure) do
    points =
      adventure
      |> Map.get(:points)
      |> Enum.map(fn point ->
        point
        |> Point.set_answer_type()
        |> Point.set_last_point(adventure.points)
      end)

    adventure
    |> Map.put(:points, points)
  end

  defp completed_adventure(adventure) do
    adventure
    |> check_point_completed()
    |> check_last_point(adventure)
    |> case do
      false ->
        adventure

      true ->
        adventure
        |> Map.put(:completed, true)
        |> emit!(
          "AdventureCompleted",
          %{completed: true, user_id: adventure.user_adventure.user_id}
        )
    end
  end

  defp create_ranking(adventure) do
    adventure.completed
    |> case do
      false ->
        {:ok, adventure}

      true ->
        start_point =
          adventure.points
          |> Enum.find(fn point ->
            point.parent_point_id == nil
          end)

        user_point_start =
          adventure.user_points
          |> Enum.find(fn user_point ->
            user_point.point_id == start_point.id
          end)

        user_point_end =
          adventure.user_points
          |> Enum.find(fn user_point ->
            user_point.point_id == adventure.current_point_id
          end)

        completion_time = NaiveDateTime.diff(user_point_end.updated_at, user_point_start.inserted_at, :second)

        adventure =
          adventure
          |> emit!("RankingCreated", %{
            user_id: user_point_start.user_id,
            adventure_id: adventure.id,
            completion_time: completion_time
          })

        {:ok, adventure}
    end
  end

  defp add_user_point(adventure, params, user, point) do
    user_point = %{
      user_id: user.id,
      point_id: adventure.current_point_id,
      completed: adventure |> point_completed(point, params),
      created_at: NaiveDateTime.utc_now(),
      updated_at: NaiveDateTime.utc_now()
    }

    adventure
    |> get_user_point(user_point)
    |> case do
      :error ->
        %{adventure | user_points: adventure.user_points ++ [user_point]}
        |> emit!("UserPointAdded", %{
          user_id: user_point.user_id,
          point_id: user_point.point_id,
          created_at: NaiveDateTime.utc_now(),
          completed: user_point.completed
        })

      result ->
        user_points =
          adventure.user_points
          |> Enum.map(fn user_p ->
            cond do
              user_p == result ->
                result
                |> Map.put(:completed, user_point.completed)

              true ->
                user_p
            end
          end)

        adventure
        |> Map.put(:user_points, user_points)
        |> emit!(
          "UserPointUpdated",
          result
          |> Map.put(:completed, user_point.completed)
        )
    end
  end

  defp point_completed(%Adventure{} = adventure, point, %{answer_text: answer_text, answer_type: answer_type}) do
    adventure
    |> get_answers(point.id)
    |> case do
      [] ->
        true

      results ->
        results
        |> Enum.filter(fn %{details: %{"password" => password, "password_type" => type}} ->
          password == answer_text and type == answer_type
        end)
        |> case do
          [] -> false
          _result -> true
        end
    end
  end

  defp get_answers(%Adventure{} = adventure, point_id) do
    adventure
    |> get_point!(point_id)
    |> Map.get(:answers)
  end

  defp get_point!(%Adventure{} = adventure, point_id) do
    adventure.points
    |> Enum.find(fn point ->
      point.id == point_id
    end)
  end

  defp get_user_point(%Adventure{} = adventure, user_point) do
    adventure.user_points
    |> Enum.find(fn point ->
      point.point_id == user_point.point_id and point.user_id == user_point.user_id
    end)
    |> case do
      nil ->
        :error

      result ->
        result
    end
  end

  defp set_current_point_id(%Adventure{} = adventure, %{id: point_id}) do
    adventure
    |> Map.put(:current_point_id, point_id)
  end

  defp check_last_point(false, _adventure), do: false

  defp check_last_point(true, adventure) do
    adventure |> get_point!(adventure.current_point_id) |> Point.check_last_point()
  end

  defp check_point_completed(adventure) do
    adventure
    |> Map.get(:user_points)
    |> Enum.find(fn point ->
      point.point_id == adventure.current_point_id
    end)
    |> case do
      nil -> false
      result -> result.completed
    end
  end
end
