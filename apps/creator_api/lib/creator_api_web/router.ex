defmodule CreatorApiWeb.Router do
  use CreatorApiWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :authenticated do
    plug(CreatorApiWeb.Plugs.Token)
  end

  scope "/api", CreatorApiWeb do
    pipe_through(:api)

    scope "/" do
      pipe_through(:authenticated)

      scope "/adventures" do
        get("/", AdventureController, :list)
        get("/:adventure_id", AdventureController, :item)
        get("/statistics", AdventureController, :statistics)

        patch("/", AdventureController, :update)
        post("/", AdventureController, :create)

        get("/:adventure_id/qa", QAController, :list)
        post("/:adventure_id/qa", QAController, :create)
      end

      scope "/clues" do
        post("/", ClueController, :create)
        patch("/", ClueController, :update)
        delete("/", ClueController, :delete)
        patch("/reorder", ClueController, :reorder)
      end

      scope "/points" do
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
end
