defmodule AdministrationApiWeb.Router do
  use AdministrationApiWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :authenticated do
    plug(AdministrationApiWeb.Plugs.Token)
  end

  scope "/api", AdministrationApiWeb do
    pipe_through(:api)

    scope "/auth" do
      post("/login", AuthController, :login)
      post("/register", AuthController, :register)

      scope "/" do
        post("/logout", AuthController, :logout)
      end
    end

    scope "/creator", Creator do
      pipe_through(:authenticated)

      scope "/adventures" do
        get("/", AdventureController, :list)
        get("/:adventure_id", AdventureController, :item)
      end
    end
  end

  scope "/api/ping", AdministrationApiWeb do
    pipe_through(:api)

    get("/", PingController, :ping)
  end
end
