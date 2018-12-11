defmodule Domain.Adventure.Adventure do
  alias Domain.Adventure.{
    Adventure,
    Point,
    UserPoint
  }
  use Ecto.Schema
  use Domain.Event, "Adventure"
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:name, :string)
    field(:description, :string)
    field(:min_time, :integer)
    field(:max_time, :integer)
    field(:difficulty_level, :integer)
    field(:language, :string)
    embeds_many(:points, Point)
    embeds_many(:user_points, UserPoint)
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

  def check_answer_and_time(%Adventure{} = adventure) do
    adventure.answers
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

  def find_answer_type(%Adventure{} = adventure) do
    adventure.answers
    |> case do
      [] -> {:ok, nil} 
      result ->
        %{details: %{"password_type" => type}} = result
        |> Enum.filter(fn answer -> 
          answer.type == "password"
        end)
        |> List.first()
        {:ok, type}
    end
  end
  
  def find_answer_type!(%Adventure{} = adventure) do
    adventure.answers
    |> case do
      [] -> nil 
      result ->
        %{details: %{"password_type" => type}} = result
        |> Enum.filter(fn answer -> 
          answer.type == "password"
        end)
        |> List.first()
        type
    end
  end

  def resolve(%Adventure{}, %{answer_text: nil, answer_type: nil}), do: {:ok, :no_answer}
  def resolve(%Adventure{} = adventure, %{answer_text: answer_text, answer_type: answer_type}) do
    adventure.answers
    |> Enum.filter(fn %{details: %{"password" => password, "password_type" => type}} -> 
      password == answer_text and type == answer_type
    end)
    |> case do 
      [] -> {:error, :wrong_answer}
      _result -> {:ok, :answer_correct} 
    end
  end

  def get_user_point(%Adventure{} = adventure, user_point) do
    
  end

  def add_user_point(adventure, user_point) do
    adventure
    |> get_user_point(user_point)
    |> case do
      :error ->
        adventure =
          %{adventure | user_points: adventure.user_points ++ [user_point]}
          |> emit("UserPointAdded", %{
            user_id: user_point.user_id,
            point_id: user_point.point_id,
            created_at: NaiveDateTime.utc_now()
          })
        {:ok, adventure}

      _ ->
        {:ok, adventure}
    end
  end


end