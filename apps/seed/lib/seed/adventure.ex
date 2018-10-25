defmodule Seed.Adventure do
  use Infrastructure.Repository.Models
  alias Ecto.Multi
  
  def seed() do
    Multi.new()
    |> Multi.insert(:adventure, build_adventure())
    |> Multi.merge(&create_points(&1[:adventure]))
    |> Infrastructure.Repository.transaction()
  end

  defp create_points(adventure) do
    %{points: points, clues: clues, answers: answers} = build_points(adventure.id)
    Multi.new()
    |> Multi.insert_all(:points, Models.Point, points, returning: true)
    |> Multi.insert_all(:clues_inserted, Models.Clue, prepare_clues(clues), returning: true)
    |> Multi.insert_all(:answers, Models.Answer, answers, returning: true)
    |> Multi.merge(fn _adventure ->
      Multi.new()
      |> Multi.run(:assets_send, fn _ -> send_assets(clues) end)
    end)
  end

  defp prepare_clues(clues) do
    clues
    |> Enum.map(fn clue -> 
      clue
      |> Map.delete(:file)
    end)
  end 

  defp send_assets(clues) do
    clues
    |> Enum.filter(fn clue ->
      clue.file != nil
    end)
    |> Enum.map(fn clue ->
      file_path = Path.join(["apps/seed/lib/helpers", clue.file])
      upload_url = Path.join([clue.point_id, clue.id, clue.file])
      send_assets_to_s3(upload_url, file_path)
    end)
    {:ok, clues}
  end

  defp build_adventure do
    Models.Adventure.build(%{
      description: "opis",
      name: "śladami Kopernika",
      difficulty_level: 3,
      published: true,
      show: true,
      language: "PL",
      code: "1234",
      min_time: "03:00:00",
      max_time: "09:00:00",
      inserted_at: NaiveDateTime.utc_now(),
      updated_at: NaiveDateTime.utc_now()
    })
  end

  defp build_points(adventure_id) do
    osiolek = %{show: true,
      position: %Geo.Point{coordinates: {18.605192, 53.010279}, srid: 4326},
      adventure_id: adventure_id,
      parent_point_id: nil,
      radius: 50,
      id: Ecto.UUID.generate(),
      inserted_at: NaiveDateTime.utc_now(),
      updated_at: NaiveDateTime.utc_now()
    }
    fontanna = %{
      show: false,
      position: %Geo.Point{coordinates: {18.599850, 53.010747}, srid: 4326},
      adventure_id: adventure_id,
      radius: 50,
      parent_point_id: osiolek.id,
      id: Ecto.UUID.generate(),
      inserted_at: NaiveDateTime.utc_now(),
      updated_at: NaiveDateTime.utc_now()
    }
    filutek = %{
      show: false,
      position: %Geo.Point{coordinates: {18.604505, 53.011100}, srid: 4326},
      adventure_id: adventure_id,
      radius: 10,
      parent_point_id: fontanna.id,
      id: Ecto.UUID.generate(),
      inserted_at: NaiveDateTime.utc_now(),
      updated_at: NaiveDateTime.utc_now()
    }
    smok = %{
      show: false,
      position: %Geo.Point{coordinates: {18.608834, 53.010770}, srid: 4326},
      adventure_id: adventure_id,
      radius: 10,
      parent_point_id: filutek.id,
      id: Ecto.UUID.generate(),
      inserted_at: NaiveDateTime.utc_now(),
      updated_at: NaiveDateTime.utc_now()
    }
    kura = %{
      show: false,
      position: %Geo.Point{coordinates: {18.60433, 53.01218}, srid: 4326},
      adventure_id: adventure_id,
      radius: 10,
      parent_point_id: smok.id,
      id: Ecto.UUID.generate(),
      inserted_at: NaiveDateTime.utc_now(),
      updated_at: NaiveDateTime.utc_now()
    }
    kopernik = %{
      show: false,
      position: %Geo.Point{coordinates: {18.604964, 53.010301}, srid: 4326},
      adventure_id: adventure_id,
      radius: 20,
      parent_point_id: kura.id,
      id: Ecto.UUID.generate(),
      inserted_at: NaiveDateTime.utc_now(),
      updated_at: NaiveDateTime.utc_now()
    }
    brama = %{
      show: false,
      position: %Geo.Point{coordinates: {18.608978, 53.008486}, srid: 4326},
      adventure_id: adventure_id,
      radius: 20,
      parent_point_id: kopernik.id,
      id: Ecto.UUID.generate(),
      inserted_at: NaiveDateTime.utc_now(),
      updated_at: NaiveDateTime.utc_now()
    }

    clues = [
      %{
        id: Ecto.UUID.generate(),
        description: "Gdy zmierzch nastaje, światło i woda opowiada tę historie.",
        type: "text",
        sort: 0,
        point_id: osiolek.id,
        tip: false,
        file: nil,
        inserted_at: NaiveDateTime.utc_now(),
        updated_at: NaiveDateTime.utc_now()
      },
      %{
        id: Ecto.UUID.generate(),
        description: nil,
        type: "audio",
        sort: 1,
        point_id: osiolek.id,
        tip: false,
        file: "witcher.mp3",
        inserted_at: NaiveDateTime.utc_now(),
        updated_at: NaiveDateTime.utc_now()
      },
      %{
        id: Ecto.UUID.generate(),
        description: "Odpowiedzi szukaj u Psa, Smoka i Kury bez Głowy.",
        type: "text",
        sort: 0,
        point_id: fontanna.id,
        tip: false,
        file: nil,
        inserted_at: NaiveDateTime.utc_now(),
        updated_at: NaiveDateTime.utc_now()
      },
      %{
        id: Ecto.UUID.generate(),
        description: nil,
        type: "image",
        sort: 0,
        point_id: filutek.id,
        tip: false,
        file: "img_1.jpg",
        inserted_at: NaiveDateTime.utc_now(),
        updated_at: NaiveDateTime.utc_now()
      },
      %{
        id: Ecto.UUID.generate(),
        description: nil,
        type: "image",
        sort: 0,
        point_id: smok.id,
        tip: false,
        file: "img_2.jpg",
        inserted_at: NaiveDateTime.utc_now(),
        updated_at: NaiveDateTime.utc_now()
      }, 
      %{
        id: Ecto.UUID.generate(),
        description: nil,
        type: "image",
        sort: 0,
        point_id: kura.id,
        tip: false,
        file: "img_3.jpg",
        inserted_at: NaiveDateTime.utc_now(),
        updated_at: NaiveDateTime.utc_now()
      },
      %{
        id: Ecto.UUID.generate(),
        description: nil,
        type: "image",
        sort: 0,
        point_id: kopernik.id,
        tip: false,
        file: "clock.png",
        inserted_at: NaiveDateTime.utc_now(),
        updated_at: NaiveDateTime.utc_now()
      },
      %{
        id: Ecto.UUID.generate(),
        description: nil,
        type: "image",
        sort: 1,
        point_id: kopernik.id,
        tip: false,
        file: "panorama.png",
        inserted_at: NaiveDateTime.utc_now(),
        updated_at: NaiveDateTime.utc_now()
      }
    ]
    points = [osiolek, fontanna, filutek, smok, kura, kopernik, brama]

    answers = [
      %{
        type: "location",
        point_id: fontanna.id,
        sort: 0,
        details: %{position: %{lat: 53.010747, lng: 18.599850}},
        inserted_at: NaiveDateTime.utc_now(),
        updated_at: NaiveDateTime.utc_now()
      },
      %{
        type: "text",
        point_id: fontanna.id,
        sort: 1,
        details: %{text: "sword of destiny"},
        inserted_at: NaiveDateTime.utc_now(),
        updated_at: NaiveDateTime.utc_now()
      },
      %{
        type: "location",
        point_id: kopernik.id,
        sort: 0,
        details: %{position: %{lat: 53.010301, lng: 18.604964}},
        inserted_at: NaiveDateTime.utc_now(),
        updated_at: NaiveDateTime.utc_now()
      },
      %{
        type: "location",
        point_id: brama.id,
        sort: 0,
        details: %{position: %{lat: 53.008486, lng: 18.608978}},
        inserted_at: NaiveDateTime.utc_now(),
        updated_at: NaiveDateTime.utc_now()
      },
      %{
        type: "location",
        point_id: filutek.id,
        sort: 0,
        details: %{position: %{lat: 53.011100, lng: 18.604505}},
        inserted_at: NaiveDateTime.utc_now(),
        updated_at: NaiveDateTime.utc_now()
      },
      %{
        type: "location",
        point_id: smok.id,
        sort: 0,
        details: %{position: %{lat: 53.010770, lng: 18.608834}},
        inserted_at: NaiveDateTime.utc_now(),
        updated_at: NaiveDateTime.utc_now()
      },
      %{
        type: "location",
        point_id: kura.id,
        sort: 0,
        details: %{position: %{lat: 53.01218, lng: 18.60433}},
        inserted_at: NaiveDateTime.utc_now(),
        updated_at: NaiveDateTime.utc_now()
      }
    ]
    %{points: points, clues: clues, answers: answers}
  end

  defp send_assets_to_s3(upload_url, file_path) do
    file_path
    |> ExAws.S3.Upload.stream_file()
    |> ExAws.S3.upload(asset_bucket(), upload_url)
    |> ExAws.request!
  end

  defp asset_bucket do
    Application.fetch_env!(:infrastructure, :asset_bucket)
  end

end