defmodule Domain.AdventureReview.Repository.Message do
  use Infrastructure.Repository.Models
  use Domain.Repository
  alias Infrastructure.Repository
  alias Infrastructure.Repository.Models
  import Ecto.Query

  alias Domain.AdventureReview

  def all(filter \\ %Domain.Filter{}) do
    logs =
      Models.AdventureLog
      |> apply_filter(filter)
      |> Repository.all()

    creators =
      logs
      |> Enum.filter(&(&1.type == "creator_message"))
      |> Enum.map(& &1.author_id)
      |> fetch_authors(:creator)

    administrators =
      logs
      |> Enum.filter(&(&1.type == "administrator_message"))
      |> Enum.map(& &1.author_id)
      |> fetch_authors(:administrator)

    logs
    |> Enum.map(&build_log(&1, administrators: administrators, creators: creators))
    |> case do
      messages -> {:ok, messages}
    end
  end

  def fetch_authors(ids, :administrator) do
    Models.Administrator
    |> where([administrator], administrator.id in ^ids)
    |> Repository.all()
    |> Enum.map(&build_author(&1, :administrator_message))
  end

  def fetch_authors(ids, :creator) do
    Models.Creator
    |> where([creator], creator.id in ^ids)
    |> Repository.all()
    |> Enum.map(&build_author(&1, :creator_message))
  end

  def fetch_authors(_, _) do
    []
  end

  defp build_author(nil, type) do
    %AdventureReview.Message.Author{
      id: Ecto.UUID.generate(),
      name: "Event",
      email: nil,
      type: type
    }
  end

  defp build_author(author_data, type) do
    %AdventureReview.Message.Author{
      id: author_data.id,
      name: author_data.name,
      email: author_data.email,
      type: type
    }
  end

  defp build_log(%{id: id, content: nil, created_at: created_at, adventure_id: adventure_id, type: type, author_id: nil}, _) do
    %AdventureReview.Message{
      id: id,
      content: nil,
      created_at: created_at,
      adventure_id: adventure_id,
      author: type
    }
  end

  defp build_log(%{id: id, content: content, created_at: created_at, adventure_id: adventure_id, type: type, author_id: author_id}, related_data)
       when type in ["administrator_message", "creator_message"] do
    administrators = Keyword.get(related_data, :administrators, [])
    creators = Keyword.get(related_data, :creators, [])

    author =
      type
      |> case do
        "administrator_message" -> administrators |> Enum.find(&(&1.id == author_id))
        "creator_message" -> creators |> Enum.find(&(&1.id == author_id))
      end

    %AdventureReview.Message{
      id: id,
      content: content,
      created_at: created_at,
      adventure_id: adventure_id,
      author: author
    }
  end

  defp apply_filter(query, filter) do
    query
    |> apply_filters(filter)
    |> apply_pagination(filter)
  end

  defp apply_pagination(query, filter = %Domain.Filter{}) do
    query
    |> limit(^Domain.Filter.limit(filter))
    |> offset(^Domain.Filter.offset(filter))
  end

  defp apply_filters(query, filter = %Domain.Filter{}) do
    filter
    |> Domain.Filter.filters()
    |> Enum.reduce(query, fn {filter_name, filter_value}, query ->
      do_filter(query, filter_name, filter_value)
    end)
  end

  defp do_filter(query, :timestamp, timestamp) do
    query
    |> where([logs], logs.created_at <= ^(timestamp |> Timex.from_unix()))
  end

  defp do_filter(query, :adventure_id, id) do
    query
    |> where([logs], logs.adventure_id == ^id)
  end

  defp do_filter(query, :creator_id, id) do
    query
    |> do_filter(:is_creator, true)
    |> where([logs], logs.author_id == ^id)
  end

  defp do_filter(query, :administrator_id, id) do
    query
    |> do_filter(:is_administrator, true)
    |> where([logs], logs.author_id == ^id)
  end

  defp do_filter(query, :is_administrator, true) do
    query
    |> where([logs], logs.author_type == ^"administrator")
  end

  defp do_filter(query, :is_administrator, false) do
    query
    |> where([logs], logs.author_type != ^"administrator")
  end

  defp do_filter(query, :is_creator, true) do
    query
    |> where([logs], logs.author_type == ^"creator")
  end

  defp do_filter(query, :is_creator, false) do
    query
    |> where([logs], logs.author_type != ^"creator")
  end

  defp do_filter(query, :is_event, true) do
    query
    |> where([logs], is_nil(logs.author_type))
  end

  defp do_filter(query, :is_event, false) do
    query
    |> where([logs], not is_nil(logs.author_type))
  end

  defp do_filter(query, _, _) do
    query
  end
end
