defmodule CreatorApiWeb.Router do
  use CreatorApiWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :authenticated do
    plug(CreatorApiWeb.Plugs.Token)
  end

  pipeline :logged do
    plug(Plug.Logger)
    plug(CreatorApiWeb.Plugs.ParamLogger)
  end

  scope "/api", CreatorApiWeb do
    pipe_through([:api, :logged])

    scope "/" do
      pipe_through(:authenticated)

      scope "/adventures" do
        get("/", AdventureController, :list)
        get("/statistics", AdventureController, :statistics)
        get("/:adventure_id", AdventureController, :item)
        post("/main_image_url", AdventureController, :upload_asset)
        post("/gallery_image/upload_url", AdventureController, :gallery_image_path)

        patch("/", AdventureController, :update)
        post("/", AdventureController, :create)

        post("/send_to_pending", AdventureController, :send_to_pending)
        post("/send_to_review", AdventureController, :send_to_review)

        get("/:adventure_id/qa", QAController, :list)
        post("/:adventure_id/qa", QAController, :create)
      end

      scope "/clues" do
        get("/:id", ClueController, :item)
        post("/", ClueController, :create)
        patch("/", ClueController, :update)
        post("/upload_asset", ClueController, :upload_file_path)
        delete("/", ClueController, :delete)
        patch("/reorder", ClueController, :reorder)
      end

      scope "/points" do
        get("/", PointController, :list)
        get("/:id", PointController, :item)
        post("/", PointController, :create)
        patch("/", PointController, :update)
        delete("/", PointController, :delete)
        patch("/reorder", PointController, :reorder)
      end
    end

    scope "/auth" do
      post("/login", AuthController, :login)
      post("/register", AuthController, :register)

      scope "/" do
        post("/logout", AuthController, :logout)
      end
    end
  end

  scope "/api/ping", CreatorApiWeb do
    pipe_through(:api)

    get("/", PingController, :ping)
  end
end
