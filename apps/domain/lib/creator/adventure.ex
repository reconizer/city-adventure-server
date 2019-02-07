defmodule Domain.Creator.Adventure do
  use Ecto.Schema
  use Domain.Event, "Creator.Adventure"
  import Ecto.Changeset, only: [cast: 3, validate_required: 2, cast_embed: 2, apply_changes: 1]

  alias Domain.Creator.Adventure

  @type t :: %__MODULE__{}
  @type ok_t :: {:ok, t()}
  @type error :: {:error, any()}
  @type entity :: ok_t() | error()

  @type clue_order :: %{id: Ecto.UUID.t(), point_id: Ecto.UUID.t()}
  @type clue_orders :: [clue_order]
  @type point_order :: %{id: Ecto.UUID.t(), parent_point_id: Ecto.UUID.t()}
  @type point_orders :: [point_order]

  @type add_clue_params :: %{
          required(:id) => Ecto.UUID.t(),
          required(:point_id) => Ecto.UUID.t(),
          required(:type) => String.t(),
          required(:description) => String.t(),
          required(:tip) => :boolean,
          optional(:url) => String.t()
        }

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field(:creator_id, :binary_id)
    field(:name, :string)
    field(:description, :string)
    field(:language, :string)
    field(:difficulty_level, :integer)
    field(:min_time, :integer)
    field(:max_time, :integer)
    field(:show, :boolean)
    field(:status, :string)
    field(:rating, :decimal)
    embeds_many(:points, Adventure.Point)
    embeds_one(:asset, Adventure.Asset)
    embeds_many(:images, Adventure.Image)

    aggregate_fields()
  end

  @fields ~w(id name creator_id description language difficulty_level min_time max_time show status)a
  @required_fields ~w(id name creator_id)a

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> cast_embed(:points)
  end

  def new(%{id: id, name: name, creator_id: creator_id, position: %{lat: lat, lng: lng}}) do
    %Adventure{
      id: id
    }
    |> changeset(%{
      status: "pending",
      creator_id: creator_id,
      name: name,
      difficulty_level: 1
    })
    |> case do
      %{valid?: true} = changeset ->
        {:ok, changeset |> apply_changes}

      changeset ->
        {:error, changeset}
    end
    |> case do
      {:error, _} = error ->
        error

      {:ok, adventure} ->
        adventure
        |> emit("Created", %{
          creator_id: adventure.creator_id,
          name: adventure.name
        })
        |> add_point(%{
          id: Ecto.UUID.generate(),
          parent_point_id: nil,
          radius: 10,
          show: true,
          position: %{
            lat: lat,
            lng: lng
          }
        })
    end
  end

  @spec send_to_review(t() | entity()) :: entity()
  def send_to_review({:ok, adventure}), do: send_to_review(adventure)
  def send_to_review({:error, _} = error), do: error

  def send_to_review(adventure) do
    adventure
    |> can_be_sent_to_review?
    |> case do
      true ->
        adventure
        |> changeset(%{
          status: "in_review"
        })
        |> case do
          %{valid?: true} = changeset ->
            changeset
            |> apply_changes
            |> emit("SentToReview", changeset.changes)

          changeset ->
            {:error, changeset}
        end

      false ->
        {:error, {:adventure_id, "cannot be sent to in review state"}}
    end
  end

  @spec send_to_pending(t() | entity()) :: entity()
  def send_to_pending({:ok, adventure}), do: send_to_pending(adventure)
  def send_to_pending({:error, _} = error), do: error

  def send_to_pending(adventure) do
    adventure
    |> can_be_sent_to_pending?
    |> case do
      true ->
        adventure
        |> changeset(%{
          status: "pending"
        })
        |> case do
          %{valid?: true} = changeset ->
            changeset
            |> apply_changes
            |> emit("SentToPending", changeset.changes)

          changeset ->
            {:error, changeset}
        end

      false ->
        {:error, {:adventure_id, "cannot be sent to pending state"}}
    end
  end

  @spec can_be_sent_to_pending?(t() | entity()) :: true | false | error
  def can_be_sent_to_pending?({:ok, adventure}), do: can_be_sent_to_pending?(adventure)
  def can_be_sent_to_pending?({:error, _} = error), do: error

  def can_be_sent_to_pending?(adventure) do
    adventure.status in ["rejected", "unpublished"]
  end

  @spec can_be_sent_to_review?(t() | entity()) :: true | false | error
  def can_be_sent_to_review?({:ok, adventure}), do: can_be_sent_to_review?(adventure)
  def can_be_sent_to_review?({:error, _} = error), do: error

  def can_be_sent_to_review?(adventure) do
    adventure.status == "pending"
  end

  @spec change(t() | entity(), Map.t()) :: entity()
  def change({:ok, adventure}, params), do: change(adventure, params)
  def change({:error, _} = error, _), do: error

  def change(adventure, params) do
    adventure
    |> changeset(params)
    |> case do
      %{valid?: true} = changeset ->
        changeset
        |> apply_changes
        |> emit("Changed", changeset.changes)

      changeset ->
        {:error, changeset}
    end
  end

  @spec add_point(t() | entity(), Map.t()) :: entity()
  def add_point({:ok, adventure}, params), do: add_point(adventure, params)
  def add_point({:error, _} = error, _), do: error

  def add_point(adventure, %{
        id: id,
        position: %{lat: lat, lng: lng},
        radius: radius,
        parent_point_id: parent_point_id,
        show: show
      }) do
    Adventure.Point.new(%{
      id: id,
      parent_point_id: parent_point_id,
      radius: radius,
      lat: lat,
      lng: lng,
      show: show
    })
    |> case do
      {:ok, point} ->
        adventure
        |> do_add_point(point)
        |> emit("PointAdded", %{
          id: point.id,
          parent_point_id: parent_point_id,
          radius: radius,
          show: show,
          lat: lat,
          lng: lng
        })

      error ->
        error
    end
  end

  @spec change_point(t() | entity(), Map.t()) :: entity()
  def change_point({:ok, adventure}, params), do: change_point(adventure, params)
  def change_point({:error, _} = error, _), do: error

  def change_point(adventure, %{id: point_id} = params) do
    adventure
    |> get_point(point_id)
    |> Adventure.Point.change(params)
    |> case do
      {:ok, {point, point_changes}} ->
        adventure
        |> do_replace_point(point)
        |> emit("PointChanged", point_changes |> Map.put(:id, point.id))

      {:error, _} = error ->
        error
    end
  end

  @spec remove_point(t() | entity(), Ecto.UUID.t()) :: entity()
  def remove_point({:ok, adventure}, point_id), do: remove_point(adventure, point_id)
  def remove_point({:error, _} = error, _), do: error

  def remove_point(adventure, point_id) do
    adventure
    |> get_point(point_id)
    |> case do
      {:error, _} = error ->
        error

      {:ok, point} ->
        adventure
        |> get_point_children(point.id)
        |> case do
          [] ->
            adventure
            |> do_remove_point(point.id)
            |> emit("PointRemoved", %{
              id: point_id
            })

          [%{id: child_point_id}] ->
            adventure
            |> change_point(%{id: child_point_id, parent_point_id: point.parent_point_id})
            |> do_remove_point(point.id)
            |> emit("PointRemoved", %{
              id: point_id
            })
        end
    end
  end

  @spec add_clue(t() | entity(), add_clue_params()) :: entity()
  def add_clue({:ok, adventure}, clue_params), do: add_clue(adventure, clue_params)
  def add_clue({:error, _} = error, _), do: error

  def add_clue(adventure, %{id: id, point_id: point_id, type: type, description: description, tip: tip} = params) do
    adventure
    |> get_point(point_id)
    |> case do
      {:ok, point} ->
        Adventure.Clue.new(%{
          id: id,
          point_id: point_id,
          type: type,
          description: description,
          tip: tip,
          url: params |> Map.get(:url),
          sort: point |> Adventure.Point.last_clue_sort()
        })
        |> case do
          {:ok, clue} ->
            adventure
            |> do_add_clue(point_id, clue)
            |> emit("PointClueAdded", %{
              id: clue.id,
              url: clue.url,
              point_id: point_id,
              type: clue.type,
              description: clue.description,
              tip: clue.tip,
              sort: clue.sort
            })

          error ->
            error
        end

      error ->
        error
    end
  end

  @spec remove_clue(t() | entity(), Ecto.UUID.t()) :: entity()
  def remove_clue({:ok, adventure}, clue_id), do: remove_clue(adventure, clue_id)
  def remove_clue({:error, _} = error, _), do: error

  def remove_clue(adventure, clue_id) do
    adventure
    |> get_clue(clue_id)
    |> case do
      {:ok, %{point_id: point_id}} ->
        adventure
        |> do_remove_clue(clue_id)
        |> emit("PointClueRemoved", %{
          point_id: point_id,
          clue_id: clue_id
        })

      error ->
        error
    end
  end

  @spec change_clue(t() | entity(), Map.t()) :: entity()
  def change_clue({:ok, adventure}, params), do: change_clue(adventure, params)
  def change_clue({:error, _} = error, _), do: error

  def change_clue(adventure, %{id: clue_id} = params) do
    adventure
    |> get_clue(clue_id)
    |> Adventure.Clue.change(params)
    |> case do
      {:ok, {clue, clue_changes}} ->
        adventure
        |> do_replace_clue(clue.point_id, clue)
        |> emit("PointClueChanged", clue_changes |> Map.put(:id, clue.id))

      error ->
        error
    end
  end

  @spec reorder_clues(t() | entity(), clue_orders) :: entity()
  def reorder_clues({:ok, adventure}, params), do: reorder_clues(adventure, params)
  def reorder_clues({:error, _} = error, _), do: error

  def reorder_clues(adventure, clue_orders) do
    clue_orders
    |> Enum.reduce({:ok, adventure}, fn
      _, {:error, _} = error ->
        error

      clue_order_params, adventure ->
        adventure
        |> change_clue(clue_order_params)
    end)
  end

  @spec reorder_points(t() | entity(), point_orders()) :: entity()
  def reorder_points({:ok, adventure}, points_order), do: reorder_points(adventure, points_order)
  def reorder_points({:error, _} = error, _), do: error

  def reorder_points(adventure, points_order) do
    points_order
    |> Enum.reduce({:ok, adventure}, fn
      %{id: point_id, parent_point_id: parent_point_id}, {:ok, adventure} ->
        adventure
        |> change_point(%{id: point_id, parent_point_id: parent_point_id})

      _, {:error, _} = error ->
        error
    end)
    |> case do
      {:ok, adventure} ->
        adventure = adventure |> set_points(adventure.points)
        {:ok, adventure}

      error ->
        error
    end
  end

  @spec get_point_children(t(), Ecto.UUID.t()) :: [Adventure.Point.t()]
  def get_point_children(adventure, point_id) do
    adventure.points
    |> Enum.filter(&(&1.parent_point_id == point_id))
  end

  @doc """
  Orders points using their parent_point_ids and point_ids
  """
  @spec set_points(t() | entity(), [Adventure.Point.t()]) :: entity()
  def set_points({:ok, adventure}, points), do: set_points(adventure, points)
  def set_points({:error, _} = error, _points), do: error

  def set_points(adventure, points) do
    {[first_point], remaining_points} =
      points
      |> Enum.split_with(&is_nil(&1.parent_point_id))

    points =
      Stream.unfold(
        {[first_point], remaining_points},
        fn
          {_, nil} ->
            nil

          {[last_added_point | _] = ordered_points, unordered_points} ->
            unordered_points
            |> Enum.split_with(&(&1.parent_point_id == last_added_point.id))
            |> case do
              {[], []} ->
                {last_added_point, {ordered_points, nil}}

              {[new_point], []} ->
                {last_added_point, {[new_point | ordered_points], []}}

              {[new_point], new_unordered_points} ->
                {last_added_point, {[new_point | ordered_points], new_unordered_points}}
            end
        end
      )
      |> Enum.to_list()

    {:ok, %{adventure | points: points}}
  end

  @spec get_clue(t() | entity(), Ecto.UUID.t()) :: Adventure.Clue.entity()
  def get_clue({:ok, adventure}, clue_id), do: get_clue(adventure, clue_id)
  def get_clue({:error, _} = error, _), do: error

  def get_clue(adventure, clue_id) do
    adventure.points
    |> Enum.flat_map(& &1.clues)
    |> Enum.find(&(&1.id == clue_id))
    |> case do
      nil -> {:error, {:clue_id, "not found in adventure"}}
      clue -> {:ok, clue}
    end
  end

  @spec get_last_point(t() | entity()) :: Adventure.Point.entity()
  def get_last_point({:ok, adventure}), do: get_last_point(adventure)
  def get_last_point({:error, _} = error), do: error

  def get_last_point(adventure) do
    adventure.points
    |> Enum.reverse()
    |> case do
      [last_point | _] -> {:ok, last_point}
      _ -> {:error, "no points in adventure"}
    end
  end

  @spec do_add_clue(t() | entity(), Ecto.UUID.t(), Adventure.Clue.t()) :: entity()
  defp do_add_clue({:ok, adventure}, point_id, clue), do: do_add_clue(adventure, point_id, clue)
  defp do_add_clue({:error, _} = error, _, _), do: error

  defp do_add_clue(adventure, point_id, clue) do
    adventure
    |> get_point(point_id)
    |> Adventure.Point.add_clue(clue)
    |> case do
      {:ok, point} ->
        adventure
        |> do_replace_point(point)

      error ->
        error
    end
  end

  @spec do_remove_clue(t() | entity(), Ecto.UUID.t()) :: entity()
  defp do_remove_clue({:ok, adventure}, clue_id), do: do_remove_clue(adventure, clue_id)
  defp do_remove_clue({:error, _} = error, _), do: error

  defp do_remove_clue(adventure, clue_id) do
    adventure
    |> get_clue(clue_id)
    |> case do
      {:ok, clue} ->
        adventure
        |> Adventure.get_point(clue.point_id)
        |> Adventure.Point.remove_clue(clue_id)
        |> case do
          {:ok, point} ->
            adventure
            |> do_replace_point(point)

          error ->
            error
        end

      error ->
        error
    end
  end

  @spec do_replace_clue(t() | entity(), Ecto.UUID.t(), Adventure.Clue.t()) :: entity()
  defp do_replace_clue({:ok, adventure}, point_id, clue), do: do_replace_clue(adventure, point_id, clue)
  defp do_replace_clue({:error, _} = error, _, _), do: error

  defp do_replace_clue(adventure, point_id, clue) do
    adventure
    |> get_point(point_id)
    |> Adventure.Point.replace_clue(clue)
    |> case do
      {:ok, point} ->
        adventure
        |> do_replace_point(point)

      error ->
        error
    end
  end

  @spec get_point(t() | entity(), Ecto.UUID.t()) :: Aggregate.Point.entity()
  def get_point({:ok, adventure}, point_id), do: get_point(adventure, point_id)
  def get_point({:error, _} = error, _), do: error

  def get_point(adventure, point_id) do
    adventure.points
    |> Enum.find(&(&1.id == point_id))
    |> case do
      nil -> {:error, {:point_id, "not found in adventure"}}
      point -> {:ok, point}
    end
  end

  @spec do_add_point(t() | entity(), Adventure.Point.t()) :: entity()
  defp do_add_point({:ok, adventure}, point), do: do_add_point(adventure, point)
  defp do_add_point({:error, _} = error, _), do: error

  defp do_add_point(adventure, point) do
    new_points = adventure.points ++ [point]

    {:ok, %{adventure | points: new_points}}
  end

  @spec do_remove_point(t() | entity(), Ecto.UUID.t()) :: entity()
  defp do_remove_point({:ok, adventure}, point_id), do: do_remove_point(adventure, point_id)
  defp do_remove_point({:error, _} = error, _), do: error

  defp do_remove_point(adventure, point_id) do
    new_points = adventure.points |> Enum.reject(&(&1.id == point_id))

    {:ok, %{adventure | points: new_points}}
  end

  @spec do_replace_point(t() | entity(), Adventure.Point.t()) :: entity()
  defp do_replace_point({:ok, adventure}, point), do: do_replace_point(adventure, point)
  defp do_replace_point({:error, _} = error, _), do: error

  defp do_replace_point(adventure, %{id: point_id} = point) do
    adventure.points
    |> Enum.map(fn
      %{id: ^point_id} -> point
      point -> point
    end)
    |> case do
      points -> {:ok, %{adventure | points: points}}
    end
  end
end
