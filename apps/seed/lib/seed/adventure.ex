defmodule Seed.Adventure do
  use Infrastructure.Repository.Models
  alias Ecto.Multi

  def seed() do
    Multi.new()
    |> Multi.insert(:user_avatar, build_user_avatar())
    |> Multi.insert(:creator_image, build_creator_image())
    |> Multi.insert_all(:users, Models.User, build_users(), returning: true)
    |> Multi.merge(fn %{creator_image: image, user_avatar: avatar, users: {_, users}} ->
      Multi.new()
      |> Multi.insert(:creator, build_creator(image))
      |> Multi.insert_all(:users_add_avatar, Models.Avatar, build_avatars(users, avatar))
    end)
    |> Multi.insert(:adventure_image, build_adventure_image())
    |> Multi.insert_all(:gallery, Models.Asset, build_gallery(), returning: true)
    |> Multi.merge(fn %{creator: creator, user_avatar: user_avatar, creator_image: creator_image, adventure_image: image, gallery: {_, gallery}} ->
      Multi.new()
      |> Multi.insert(:adventure, build_adventure(creator.id, image))
      |> Multi.merge(fn adventure ->
        create_adventure_image(adventure, gallery)
      end)
      |> Multi.merge(fn _adventure ->
        gallery = [image | gallery]
        gallery = [creator_image | gallery]
        gallery = [user_avatar | gallery]

        Multi.new()
        |> Multi.run(:send_assets, fn _, _ -> send_assets(gallery) end)
      end)
    end)
    |> Multi.merge(&create_points/1)
    |> Infrastructure.Repository.transaction()
  end

  def seed_adventure_by_creator(creator_id) do
    Multi.new()
    |> Multi.insert(:adventure_image, build_adventure_image())
    |> Multi.insert_all(:gallery, Models.Asset, build_gallery(), returning: true)
    |> Multi.merge(fn %{adventure_image: image, gallery: {_, gallery}} ->
      Multi.new()
      |> Multi.insert(:adventure, build_adventure(creator_id, image))
      |> Multi.merge(fn adventure ->
        create_adventure_image(adventure, gallery)
      end)
      |> Multi.merge(fn _adventure ->
        gallery = [image | gallery]

        Multi.new()
        |> Multi.run(:send_assets, fn _, _ -> send_assets(gallery) end)
      end)
    end)
    |> Multi.merge(&create_points_without_resolve/1)
    |> Infrastructure.Repository.transaction()
  end

  defp create_adventure_image(%{adventure: adventure}, assets) do
    Multi.new()
    |> Multi.insert_all(:images, Models.Image, preper_image(assets, adventure), returning: true)
  end

  defp create_points(%{adventure: adventure, users: {_, users}}) do
    %{points: points, clues: clues, answers: answers, assets: assets} = build_points(adventure.id)

    Multi.new()
    |> Multi.insert_all(:points, Models.Point, points, returning: true)
    |> Multi.insert_all(:user_adventure, Models.UserAdventure, build_user_adventure(adventure, users), returning: true)
    |> Multi.insert_all(:ranking, Models.Ranking, build_ranking(adventure, users), returning: true)
    |> Multi.insert_all(:rating, Models.AdventureRating, build_rating(adventure, users), returning: true)
    |> Multi.insert_all(:assets, Models.Asset, assets, returning: true)
    |> Multi.insert_all(:clues_inserted, Models.Clue, clues, returning: true)
    |> Multi.insert_all(:answers, Models.Answer, answers, returning: true)
    |> Multi.merge(fn %{assets: {_, assets}} ->
      Multi.new()
      |> Multi.run(:assets_send, fn _, _ -> send_assets(assets) end)
    end)
  end

  defp create_points_without_resolve(%{adventure: adventure}) do
    %{points: points, clues: clues, answers: answers, assets: assets} = build_points(adventure.id)

    Multi.new()
    |> Multi.insert_all(:points, Models.Point, points, returning: true)
    |> Multi.insert_all(:assets, Models.Asset, assets, returning: true)
    |> Multi.insert_all(:clues_inserted, Models.Clue, clues, returning: true)
    |> Multi.insert_all(:answers, Models.Answer, answers, returning: true)
    |> Multi.merge(fn %{assets: {_, assets}} ->
      Multi.new()
      |> Multi.run(:assets_send, fn _, _ -> send_assets(assets) end)
    end)
  end

  defp build_avatars(users, asset) do
    users
    |> Enum.map(fn user ->
      %{
        asset_id: asset.id,
        user_id: user.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      }
    end)
  end

  defp build_user_adventure(adventure, users) do
    users
    |> Enum.map(fn user ->
      %{
        adventure_id: adventure.id,
        user_id: user.id,
        completed: true,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      }
    end)
  end

  defp build_user_avatar() do
    Models.Asset.build(%{
      id: Ecto.UUID.generate(),
      type: "avatar",
      extension: "jpg",
      name: "avatar",
      inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    })
  end

  defp build_ranking(adventure, users) do
    users
    |> Enum.map(fn user ->
      %{
        adventure_id: adventure.id,
        user_id: user.id,
        completion_time: Enum.random([6700, 6720, 6800, 6840]),
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      }
    end)
  end

  defp build_rating(adventure, users) do
    users
    |> Enum.map(fn user ->
      %{
        adventure_id: adventure.id,
        user_id: user.id,
        rating: Enum.random(1..5),
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      }
    end)
  end

  defp preper_image(assets, adventure) do
    assets
    |> Enum.with_index(1)
    |> Enum.map(fn {asset, sort} ->
      %{
        sort: sort,
        asset_id: asset.id,
        adventure_id: adventure.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      }
    end)
  end

  defp build_creator_image() do
    Models.Asset.build(%{
      id: Ecto.UUID.generate(),
      type: "image",
      extension: "png",
      name: "creator",
      inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    })
  end

  defp build_gallery() do
    tor1 = %{
      id: Ecto.UUID.generate(),
      type: "image",
      extension: "jpg",
      name: "tor1",
      inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    }

    tor2 = %{
      id: Ecto.UUID.generate(),
      type: "image",
      extension: "jpg",
      name: "tor2",
      inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    }

    [tor1, tor2]
  end

  defp send_asset(asset) do
    file_path = Path.join([Application.app_dir(:seed), "priv", "helpers", Enum.join([asset.name, asset.extension], ".")])
    upload_url = Path.join([asset.type, asset.id, "#{asset.name}.#{asset.extension}"])
    send_assets_to_s3(upload_url, file_path)
  end

  defp send_assets(assets) do
    assets
    |> Enum.map(fn asset ->
      asset
      |> send_asset()
    end)

    {:ok, assets}
  end

  defp build_adventure_image() do
    Models.Asset.build(%{
      id: Ecto.UUID.generate(),
      type: "image",
      extension: "jpg",
      name: "tor3",
      inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    })
  end

  defp build_adventure(creator_id, image) do
    Models.Adventure.build(%{
      description: "Wyrusz w fascynującą wyprawę po Toruńskiej starówce",
      name: "śladami Kopernika",
      difficulty_level: 3,
      published: true,
      show: true,
      language: "PL",
      code: "1234",
      min_time: 3000,
      max_time: 7800,
      creator_id: creator_id,
      asset_id: image.id,
      inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    })
  end

  defp build_creator(image) do
    Models.Creator.build(%{
      description: "Moje przygody są najlepsze",
      name: "AdventureBuilder",
      approved: true,
      address1: "Szeroka 9",
      city: "Toruń",
      country: "POL",
      asset_id: image.id,
      email: "builder@adventure.com",
      password_digest: Comeonin.Bcrypt.hashpwsalt("1234"),
      zip_code: "87-100",
      inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    })
  end

  defp build_users() do
    [
      %{
        id: Ecto.UUID.generate(),
        email: "martin@gmail.com",
        nick: "martin",
        password_digest: Comeonin.Bcrypt.hashpwsalt("1234"),
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        id: Ecto.UUID.generate(),
        email: "adam@gmail.com",
        nick: "adam",
        password_digest: Comeonin.Bcrypt.hashpwsalt("1234"),
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        id: Ecto.UUID.generate(),
        email: "luck@gmail.com",
        nick: "luck",
        password_digest: Comeonin.Bcrypt.hashpwsalt("1234"),
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        id: Ecto.UUID.generate(),
        email: "nick@gmail.com",
        nick: "nick",
        password_digest: Comeonin.Bcrypt.hashpwsalt("1234"),
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        id: Ecto.UUID.generate(),
        email: "simon@gmail.com",
        nick: "simon",
        password_digest: Comeonin.Bcrypt.hashpwsalt("1234"),
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        id: Ecto.UUID.generate(),
        email: "paul@gmail.com",
        nick: "paul",
        password_digest: Comeonin.Bcrypt.hashpwsalt("1234"),
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      }
    ]
  end

  defp build_points(adventure_id) do
    osiolek = %{
      show: true,
      position: %Geo.Point{coordinates: {18.605192, 53.010279}, srid: 4326},
      adventure_id: adventure_id,
      parent_point_id: nil,
      radius: 50,
      id: Ecto.UUID.generate(),
      inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    }

    fontanna = %{
      show: false,
      position: %Geo.Point{coordinates: {18.599850, 53.010747}, srid: 4326},
      adventure_id: adventure_id,
      radius: 50,
      parent_point_id: osiolek.id,
      id: Ecto.UUID.generate(),
      inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    }

    filutek = %{
      show: false,
      position: %Geo.Point{coordinates: {18.604505, 53.011100}, srid: 4326},
      adventure_id: adventure_id,
      radius: 10,
      parent_point_id: fontanna.id,
      id: Ecto.UUID.generate(),
      inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    }

    smok = %{
      show: false,
      position: %Geo.Point{coordinates: {18.608834, 53.010770}, srid: 4326},
      adventure_id: adventure_id,
      radius: 10,
      parent_point_id: filutek.id,
      id: Ecto.UUID.generate(),
      inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    }

    kura = %{
      show: false,
      position: %Geo.Point{coordinates: {18.60433, 53.01218}, srid: 4326},
      adventure_id: adventure_id,
      radius: 10,
      parent_point_id: smok.id,
      id: Ecto.UUID.generate(),
      inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    }

    kopernik = %{
      show: false,
      position: %Geo.Point{coordinates: {18.604964, 53.010301}, srid: 4326},
      adventure_id: adventure_id,
      radius: 20,
      parent_point_id: kura.id,
      id: Ecto.UUID.generate(),
      inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    }

    brama = %{
      show: false,
      position: %Geo.Point{coordinates: {18.608978, 53.008486}, srid: 4326},
      adventure_id: adventure_id,
      radius: 20,
      parent_point_id: kopernik.id,
      id: Ecto.UUID.generate(),
      inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    }

    witcher = %{
      id: Ecto.UUID.generate(),
      type: "clue_audio",
      extension: "mp3",
      name: "witcher",
      inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    }

    img_1 = %{
      id: Ecto.UUID.generate(),
      type: "clue_image",
      extension: "jpg",
      name: "img_1",
      inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    }

    img_2 = %{
      id: Ecto.UUID.generate(),
      type: "clue_image",
      extension: "jpg",
      name: "img_2",
      inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    }

    img_3 = %{
      id: Ecto.UUID.generate(),
      type: "clue_image",
      extension: "jpg",
      name: "img_3",
      inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    }

    clock = %{
      id: Ecto.UUID.generate(),
      type: "clue_image",
      extension: "png",
      name: "clock",
      inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    }

    panorama = %{
      id: Ecto.UUID.generate(),
      type: "clue_image",
      extension: "png",
      name: "panorama",
      inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    }

    assets = [witcher, img_1, img_2, img_3, clock, panorama]

    clues = [
      %{
        id: Ecto.UUID.generate(),
        description: "Gdy zmierzch nastaje, światło i woda opowiada tę historie.",
        type: "text",
        sort: 0,
        point_id: osiolek.id,
        tip: false,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        id: Ecto.UUID.generate(),
        description: nil,
        type: "audio",
        sort: 1,
        point_id: osiolek.id,
        tip: false,
        asset_id: witcher.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        id: Ecto.UUID.generate(),
        description: "Odpowiedzi szukaj u Psa, Smoka i Kury bez Głowy.",
        type: "text",
        sort: 0,
        point_id: fontanna.id,
        tip: false,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        id: Ecto.UUID.generate(),
        description: nil,
        type: "image",
        sort: 0,
        point_id: filutek.id,
        tip: false,
        asset_id: img_1.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        id: Ecto.UUID.generate(),
        description: nil,
        type: "image",
        sort: 0,
        point_id: smok.id,
        tip: false,
        asset_id: img_2.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        id: Ecto.UUID.generate(),
        description: nil,
        type: "image",
        sort: 0,
        point_id: kura.id,
        tip: false,
        asset_id: img_3.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        id: Ecto.UUID.generate(),
        description: nil,
        type: "image",
        sort: 0,
        point_id: kopernik.id,
        tip: false,
        asset_id: clock.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      },
      %{
        id: Ecto.UUID.generate(),
        description: nil,
        type: "image",
        sort: 1,
        point_id: kopernik.id,
        tip: false,
        asset_id: panorama.id,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      }
    ]

    points = [osiolek, fontanna, filutek, smok, kura, kopernik, brama]

    answers = [
      %{
        type: "password",
        point_id: fontanna.id,
        details: %{password: "sword of destiny", password_type: "text"},
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      }
    ]

    %{points: points, clues: clues, answers: answers, assets: assets}
  end

  defp send_assets_to_s3(upload_url, file_path) do
    file_path
    |> ExAws.S3.Upload.stream_file()
    |> ExAws.S3.upload(asset_bucket(), upload_url)
    |> ExAws.request!()
  end

  defp asset_bucket do
    Application.fetch_env!(:infrastructure, :asset_bucket)
  end
end
