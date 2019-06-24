defmodule AdministrationApiWeb.Router do
  use AdministrationApiWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :authenticated do
    plug(AdministrationApiWeb.Plugs.Token)
  end

  pipeline :logged do
    plug(Plug.Logger)
    plug(AdministrationApiWeb.Plugs.ParamLogger)
  end

  scope "/api", AdministrationApiWeb do
    pipe_through([:api, :logged])

    scope "/" do
      pipe_through(:authenticated)

      scope "/adventures" do
        get("/", AdventureController, :list)
        get("/statistics", AdventureController, :statistics)

        patch("/", AdventureController, :update)
        post("/", AdventureController, :create)

        post("/send_to_pending", AdventureController, :send_to_pending)
        post("/send_to_review", AdventureController, :send_to_review)

        get("/:adventure_id/qa", QAController, :list)
        post("/:adventure_id/qa", QAController, :create)
        get("/:adventure_id", AdventureController, :item)
      end

      scope "/clues" do
        get("/:id", ClueController, :item)
        post("/", ClueController, :create)
        patch("/", ClueController, :update)
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

  scope "/api/ping", AdministrationApiWeb do
    pipe_through(:api)

    get("/", PingController, :ping)
  end
end
