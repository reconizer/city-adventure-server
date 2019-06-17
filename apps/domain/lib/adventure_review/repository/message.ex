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
      |> Enum.filter(&(&1.author_type == "creator"))
      |> Enum.map(& &1.author_id)
      |> fetch_authors(:creator)

    administrators =
      logs
      |> Enum.filter(&(&1.author_type == "administrator"))
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
    |> Enum.map(&build_author(&1, :administrator))
  end

  def fetch_authors(ids, :creator) do
    Models.Creator
    |> where([creator], creator.id in ^ids)
    |> Repository.all()
    |> Enum.map(&build_author(&1, :creator))
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

  defp build_log(%{content: content, created_at: created_at, adventure_id: adventure_id, author_type: author_type, author_id: author_id}, related_data)
       when author_type in ["administrator", "creator"] do
    administrators = Keyword.get(related_data, :administrators, [])
    creators = Keyword.get(related_data, :creators, [])

    author =
      author_type
      |> case do
        "administrator" -> administrators |> Enum.find(&(&1.id == author_id))
        "creator" -> creators |> Enum.find(&(&1.id == author_id))
      end

    %AdventureReview.Message{
      content: content,
      created_at: created_at,
      adventure_id: adventure_id,
      author: author
    }
  end

  defp build_log(%{content: content, created_at: created_at, adventure_id: adventure_id, author_type: nil, author_id: nil}, _) do
    %AdventureReview.Message{
      content: content,
      created_at: created_at,
      adventure_id: adventure_id,
      author: build_author(nil, "event")
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
