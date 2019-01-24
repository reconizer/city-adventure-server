defmodule CreatorApiWeb.QAController do
  use CreatorApiWeb, :controller

  import Contract

  def list(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID
    })
    |> validate(%{
      creator_id: :required,
      adventure_id: :required
    })
    |> case do
      {:ok, params} ->
        conn
        |> resp(200, "OK")

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def create(conn, params) do
    params
    |> with_creator(conn)
    |> cast(%{
      creator_id: Ecto.UUID,
      adventure_id: Ecto.UUID,
      content: :string
    })
    |> validate(%{
      creator_id: :required,
      adventure_id: :required,
      content: :string
    })
    |> case do
      {:ok, params} ->
        conn
        |> resp(200, "OK")

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end
end
