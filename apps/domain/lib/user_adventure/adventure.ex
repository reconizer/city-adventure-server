defmodule Domain.UserAdventure.Adventure do
  alias Domain.UserAdventure.Adventure.{
    Point,
    UserAdventure,
    UserPoint,
    UserRanking,
    Asset,
    Image,
    AdventureRating
  }

  alias Domain.UserAdventure.Adventure

  use Ecto.Schema
  use Domain.Event, "UserAdventure"
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:current_point_id, Ecto.UUID)
    field(:completed, :boolean, default: false)
    field(:name, :string)
    field(:creator_id, Ecto.UUID)
    field(:description, :string)
    field(:min_time, :integer)
    field(:max_time, :integer)
    field(:difficulty_level, :integer)
    field(:language, :string)
    embeds_many(:points, Point)
    embeds_many(:user_points, UserPoint)
    embeds_one(:user_adventure, UserAdventure)
    embeds_one(:user_ranking, UserRanking)
    embeds_one(:user_rating, AdventureRating)
    embeds_one(:creator, Creator)
    embeds_one(:asset, Asset)
    embeds_many(:images, Image)

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

  def resolve_point(adventure, params, point) do
    adventure
    |> set_current_point_id(point)
    |> set_answer_type_and_last_point()
    |> add_user_point(params, point)
    |> completed_adventure()
    |> create_ranking()
  end

  def start_adventure(adventure, params, start_point) do
    adventure =
      adventure
      |> create_user_adventure(params)
      |> add_started_point(params, start_point)

    {:ok, adventure}
  end

  def find_point(adventure, %{point_id: point_id}) do
    adventure
    |> Map.get(:points)
    |> Enum.find(fn point ->
      point.id == point_id
    end)
    |> case do
      nil -> {:error, {:point, "not_found"}}
      point -> {:ok, point}
    end
  end

  def find_start_point(adventure) do
    adventure
    |> Map.get(:points)
    |> Enum.find(fn point ->
      point.parent_point_id == nil
    end)
    |> case do
      nil -> {:error, {:point, "not_found"}}
      result -> {:ok, result}
    end
  end

  def check_point_position(%Adventure{points: points, user_points: user_points}, %{position: %{lat: lat, lng: lng}}) do
    points
    |> Enum.filter(fn %{radius: radius, position: %{coordinates: {p_lng, p_lat}}} ->
      Geocalc.within?(radius, %{lat: p_lat, lng: p_lng}, %{lat: lat, lng: lng})
    end)
    |> Enum.find(fn point ->
      user_points
      |> Enum.find(fn user_p ->
        user_p.point_id == point.parent_point_id
      end)
      |> case do
        nil ->
          false

        result ->
          result
          |> Map.get(:completed)
          |> case do
            false ->
              false

            true ->
              user_points
              |> Enum.find(fn user_p ->
                user_p.point_id == point.id
              end)
              |> case do
                true -> false
                false -> true
              end
          end
      end
    end)
    |> case do
      nil -> {:error, {:point, "not_found"}}
      result -> {:ok, result}
    end
  end

  def get_discovered_points!(%Adventure{user_points: user_points, points: points}) do
    points
    |> Enum.filter(fn point ->
      completed_points_with_shown(user_points, point)
    end)
  end

  def get_discovered_points(%Adventure{} = adventure), do: {:ok, get_discovered_points!(adventure)}

  def get_added_points(%Adventure{} = adventure), do: {:ok, get_added_points!(adventure)}

  def get_added_points!(%Adventure{user_points: user_points, points: points}) do
    points
    |> Enum.filter(fn point ->
      completed_points(user_points, point)
    end)
  end

  def check_adventure_completed(%Adventure{} = adventure) do
    adventure
    |> Map.get(:completed)
    |> case do
      false -> {:ok, adventure}
      true -> {:error, {:adventure, "alredy_completed"}}
    end
  end

  def completed_points(user_points, point) do
    user_points
    |> Enum.find(fn user_point -> user_point.point_id == point.id end)
    |> case do
      nil ->
        false

      result ->
        result.completed
        |> case do
          true ->
            true

          false ->
            user_points
            |> Enum.find(fn user_point -> user_point.point_id == point.parent_point_id end)
            |> Map.get(:completed)
        end
    end
  end

  def completed_points_with_shown(user_points, point) do
    user_points
    |> Enum.find(fn user_point -> user_point.point_id == point.id end)
    |> case do
      nil ->
        point.show and
          user_points
          |> Enum.find(fn u_p ->
            u_p.point_id == point.parent_point_id
          end)
          |> case do
            nil ->
              false

            result ->
              result
              |> Map.get(:completed)
          end

      result ->
        result.completed
        |> case do
          true ->
            true

          false ->
            user_points
            |> Enum.find(fn user_point -> user_point.point_id == point.parent_point_id end)
            |> Map.get(:completed)
        end
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
          true -> {:error, {:point, "alredy_completed"}}
          false -> {:ok, adventure}
        end
    end
  end

  def check_adventure_started(%Adventure{} = adventure) do
    adventure
    |> Map.get(:user_adventure)
    |> case do
      nil -> {:ok, adventure}
      _result -> {:error, {:adventure, "alredy_started"}}
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

          true ->
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

  defp add_user_point(adventure, params, point) do
    user_point = %{
      user_id: params.user_id,
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
          |> Map.from_struct()
        )
    end
  end

  defp create_user_adventure(adventure, params) do
    user_adventure = %{
      user_id: params.user_id,
      adventure_id: adventure.id,
      completed: false,
      created_at: NaiveDateTime.utc_now(),
      updated_at: NaiveDateTime.utc_now()
    }

    %{adventure | user_adventure: user_adventure}
    |> emit!("UserAdventureAdded", %{
      user_id: user_adventure.user_id,
      adventure_id: user_adventure.adventure_id,
      created_at: NaiveDateTime.utc_now(),
      completed: user_adventure.completed
    })
  end

  defp add_started_point(adventure, params, point) do
    user_point = %{
      user_id: params.user_id,
      point_id: point.id,
      completed: true,
      created_at: NaiveDateTime.utc_now(),
      updated_at: NaiveDateTime.utc_now()
    }

    %{adventure | user_points: adventure.user_points ++ [user_point]}
    |> emit!("UserPointAdded", %{
      user_id: user_point.user_id,
      point_id: user_point.point_id,
      created_at: NaiveDateTime.utc_now(),
      completed: user_point.completed
    })
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
