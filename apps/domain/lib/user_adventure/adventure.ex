defmodule Domain.UserAdventure.Adventure do
  alias Domain.UserAdventure.{
    Adventure,
    Point,
    UserAdventure,
    UserPoint
  }
  use Ecto.Schema
  use Domain.Event, "Adventure"
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:answer_type, :string)
    field(:point_completed, :boolean)
    field(:adventure_completed, :boolean, default: false)
    field(:completed, :boolean)
    embeds_many(:points, Point)
    embeds_many(:user_points, UserPoint)
    embeds_one(:user_adventure, UserAdventure)
    embeds_many(:events, Domain.Event)
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

  def check_point_position(%Adventure{} = adventure, %{point_id: point_id, position: %{coordinates: {lng, lat}}}) do
    adventure
    |> get_point!(point_id)
    |> case do
      nil -> {:error, {:point, "not_found"}}
      %{radius: radius, position: %{coordinates: {p_lng, p_lat}}} = result -> 
        Geocalc.within?(radius, %{lat: p_lat, lng: p_lng}, %{lat: lat, lng: lng})
        |> case do
          true -> {:ok, result}
          false -> {:error, {:point, "not_found"}} 
        end
    end
  end

  def check_answer_and_time(%Adventure{} = adventure, %{point_id: point_id}) do
    adventure
    |> get_answers(point_id)
    |> Enum.filter(fn answer ->  
      answer.type == "time"
    end)
    |> List.first()
    |> case do
      nil -> {:ok, true}
      %{details: %{"starting_time" => starting_time, "duration" => duration}} ->
        time_now = Time.utc_now() |> Time.to_erl() |> :calendar.time_to_seconds()
        cond do
          starting_time <= time_now and time_now <= (starting_time + duration) ->
            {:ok, true}
          false -> {:error, :wrong_time}
        end
    end
  end
  
  def set_answer_type(%Adventure{} = adventure, %{point_id: point_id}) do
    adventure
    |> get_answers(point_id)
    |> case do
      [] -> adventure
      result ->
        result
        |> Enum.filter(fn answer -> 
          answer.type == "password"
        end)
        |> List.first()
        |> case do
          nil ->
            adventure
          %{details: %{"password_type" => type}} ->
            adventure
            |> Map.put(:answer_type, type)
        end
    end
  end

  def completed_adventure(adventure) do
    adventure.adventure_completed
    |> case do
      false -> adventure
      true -> adventure =
        adventure
        |> emit("AdventureCompleted", 
          adventure
          |> Map.put(:completed, true)
        )
        {:ok, adventure}
    end
  end

  def create_ranking(adventure, %{point_id: point_id}) do
    adventure.adventure_completed
    |> case do
      false -> 
        {:ok, adventure}
      true ->
        start_point = adventure.points 
        |> Enum.filter(fn point -> 
          point.parent_point_id == nil
        end)
        |> List.first()
        user_point_start = adventure.user_points |> Enum.filter(fn user_point -> 
          user_point.point_id == start_point.point_id
        end)
        |> List.first()
        user_point_end = adventure.user_points
        |> Enum.filter(fn user_point -> 
          user_point.point_id == point_id 
        end)
        |> List.first()
        completion_time = NaiveDateTime.diff(user_point_end.updated_at, user_point_start.inserted_at, :hours)
        adventure = adventure 
        |> emit("RankingCreated", %{
          user_id: user_point_start.user_id,
          adventure_id: adventure.id,
          completion_time: completion_time
        })
      {:ok, adventure}
    end
  end

  def add_user_point(adventure, params, user) do
    user_point = %{user_id: user.id, point_id: params.point_id}
    adventure
    |> get_user_point(user_point)
    |> case do
      :error ->
        %{adventure | user_points: adventure.user_points ++ [user_point]}
        |> emit("UserPointAdded", %{
          user_id: user_point.user_id,
          point_id: user_point.point_id,
          created_at: NaiveDateTime.utc_now(),
          completed: adventure |> point_completed(params)
        })
      result ->
        adventure
        |> emit("UserPointUpdated", 
          result
          |> Map.put(:completed, adventure |> point_completed(params))
        )
    end
  end

  def check_last_point(%Adventure{} = adventure, parent_point) do
    adventure.points
    |> Enum.filter(fn point -> 
      point.parent_point_id == parent_point.id
    end)
    |> case do
      [] -> 
        adventure
        |> Map.put(:adventure_completed, true)
      _result -> 
        adventure
        |> Map.put(:adventure_completed, false)
    end
  end

  defp point_completed(%Adventure{} = adventure, %{point_id: point_id, answer_text: answer_text, answer_type: answer_type}) do
    adventure
    |> get_answers(point_id)
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

  defp get_point(%Adventure{} = adventure, point_id), do: {:ok, adventure |> get_point!(point_id)}
  defp get_point!(%Adventure{} = adventure, point_id) do
    adventure.points
    |> Enum.filter(fn point -> 
      point.id == point_id
    end)
    |> List.first
  end 

  defp get_user_point(%Adventure{} = adventure, user_point) do
    adventure.user_points
    |> Enum.filter(fn point -> 
      point.point_id == user_point.point_id and point.user_id == user_point.user_id
    end)
    |> List.first()
    |> case do
      nil -> :error
      result ->
        result
    end
  end

end