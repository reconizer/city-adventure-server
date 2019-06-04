defmodule CreatorApiWeb.AdventureController do
  use CreatorApiWeb, :controller

  alias CreatorApiWeb.AdventureContract
  alias Domain.Creator

  def list(conn, params) do
    with {:ok, params} <- AdventureContract.list(conn, params),
         {:ok, adventures} <- Creator.Service.Adventure.get_creator_adventures(params.creator_id) do
      conn
      |> render("list.json", %{list: adventures})
    else
      {:error, error} ->
        conn
        |> handle_errors(error)
    end
  end

  def item(conn, params) do
    with {:ok, params} <- AdventureContract.item(conn, params),
         {:ok, adventure} <- Creator.Service.Adventure.get_creator_adventure(params.creator_id, params.adventure_id) do
      conn
      |> render("item.json", %{item: adventure})
    else
      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def statistics(conn, params) do
    AdventureContract.statistics(conn, params)
    |> case do
      {:ok, _params} ->
        conn
        |> put_status(200)
        |> json(%{})

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def create(conn, params) do
    AdventureContract.create(conn, params)
    |> case do
      {:ok, params} ->
        Domain.Creator.Adventure.new(params)
        |> Domain.Creator.Repository.Adventure.save()
        |> case do
          {:ok, _} ->
            Creator.Service.Adventure.get_creator_adventure(params.creator_id, params.id)
            |> case do
              {:ok, adventure} ->
                conn
                |> render("item.json", %{item: adventure})

              {:error, errors} ->
                conn
                |> handle_errors(errors)
            end

          error ->
            error
            |> handle_repository_action(conn)
        end

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def update(conn, params) do
    AdventureContract.update(conn, params)
    |> case do
      {:ok, params} ->
        Creator.Service.Adventure.get_creator_adventure(params.creator_id, params.adventure_id)
        |> Domain.Creator.Adventure.change(params)
        |> Domain.Creator.Repository.Adventure.save()
        |> handle_repository_action(conn)

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def send_to_pending(conn, params) do
    AdventureContract.send_to_pending(conn, params)
    |> case do
      {:ok, params} ->
        Creator.Service.Adventure.get_creator_adventure(params.creator_id, params.adventure_id)
        |> Domain.Creator.Adventure.send_to_pending()
        |> Domain.Creator.Repository.Adventure.save()
        |> handle_repository_action(conn)

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def send_to_review(conn, params) do
    AdventureContract.send_to_review(conn, params)
    |> case do
      {:ok, params} ->
        Creator.Service.Adventure.get_creator_adventure(params.creator_id, params.adventure_id)
        |> Domain.Creator.Adventure.send_to_review()
        |> Domain.Creator.Repository.Adventure.save()
        |> handle_repository_action(conn)

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def upload_asset(conn, params) do
    AdventureContract.upload_image(conn, params)
    |> case do
      {:ok, validate_params} ->
        Creator.Service.Adventure.get_creator_adventure(validate_params.creator_id, validate_params.adventure_id)
        |> Domain.Creator.Adventure.main_image(validate_params)
        |> Domain.Creator.Repository.Adventure.save()
        |> case do
          {:ok, adventure} ->
            conn
            |> render("upload_asset.json", %{adventure: adventure})

          {:error, errors} ->
            conn
            |> handle_errors(errors)
        end

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def gallery_image_path(conn, params) do
    AdventureContract.upload_image(conn, params)
    |> case do
      {:ok, validate_params} ->
        Creator.Service.Adventure.get_creator_adventure(validate_params.creator_id, validate_params.adventure_id)
        |> Domain.Creator.Adventure.gallery_image(validate_params)
        |> Domain.Creator.Repository.Adventure.save()
        |> case do
          {:ok, adventure} ->
            conn
            |> render("upload_image.json", %{adventure: adventure})

          {:error, errors} ->
            conn
            |> handle_errors(errors)
        end

      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def remove_gallery_image(conn, params) do
    with {:ok, %{creator_id: creator_id, adventure_id: adventure_id, image_id: image_id}} <-
           conn
           |> AdventureContract.remove_image(params),
         {:ok, creator_adventure} <- creator_id |> Creator.Service.Adventure.get_creator_adventure(adventure_id),
         {:ok, adventure} <- creator_adventure |> Domain.Creator.Adventure.remove_image(image_id),
         {:ok, adventure} <- adventure |> Domain.Creator.Repository.Adventure.save() do
      conn
      |> render("item.json", %{item: adventure})
    else
      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end

  def reorder_gallery_image(conn, params) do
    with {:ok, %{creator_id: creator_id, adventure_id: adventure_id, image_order: image_order}} <-
           conn
           |> AdventureContract.reorder_gallery(params),
         {:ok, creator_adventure} <- creator_id |> Creator.Service.Adventure.get_creator_adventure(adventure_id),
         {:ok, adventure} <- creator_adventure |> Domain.Creator.Adventure.reorder_images(image_order),
         {:ok, adventure} <- adventure |> Domain.Creator.Repository.Adventure.save() do
      conn
      |> render("item.json", %{item: adventure})
    else
      {:error, errors} ->
        conn
        |> handle_errors(errors)
    end
  end
end
