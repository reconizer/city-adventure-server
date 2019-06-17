defmodule UserApiWeb.Router do
  use UserApiWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(UserApiWeb.Plugs.CreateSession)
  end

  pipeline :api_jwt do
    plug(:accepts, ["json"])
    plug(UserApiWeb.Plugs.ParseJwt)
    plug(UserApiWeb.Plugs.CreateSession)
  end

  pipeline :logged do
    plug(Plug.Logger)
    plug(UserApiWeb.Plugs.ParamLogger)
  end

  scope "/api", UserApiWeb do
    pipe_through([:api_jwt, :logged])

    scope "/adventures" do
      get("/", AdventureController, :index)
      get("/filters", AdventureController, :index_with_filter)
      get("/user", AdventureController, :user_list)
      get("/summary/:adventure_id", AdventureController, :summary)
      get("/:adventure_id", AdventureController, :show)
      get("/:adventure_id/ranking", RankingController, :index)
      get("/:adventure_id/current_user_ranking", RankingController, :current_user_ranking)
      get("/:adventure_id/completed_points", PointController, :completed_points)
      post("/rating", AdventureController, :rating)
      post("/start", AdventureController, :start)
    end

    scope "/profile" do
      get("/", ProfileController, :show)
      get("/avatar_list", ProfileController, :avatar_list)
      post("/update", ProfileController, :update)
      post("/:creator_id/follow", ProfileController, :follow)
      post("/:creator_id/unfollow", ProfileController, :unfollow)
    end

    scope "/creator" do
      get("/adventures", CreatorController, :adventure_list)
      get("/filters", CreatorController, :creator_list)
      get("/:creator_id", CreatorController, :show)
    end

    scope "/clues" do
      get("/:adventure_id", ClueController, :index)
      get("/point/:adventure_id/:point_id", ClueController, :list_for_point)
    end

    scope "/points" do
      post("/resolve_point", PointController, :resolve_position_point)
    end
  end

  scope "/api/auth", UserApiWeb do
    pipe_through(:api)

    post("/", AuthController, :login)
    post("/register", AuthController, :register)
  end

  scope "/api/ping", UserApiWeb do
    pipe_through(:api)

    get("/", PingController, :ping)
  end
end
