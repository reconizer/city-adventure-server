defmodule UserApiWeb.Router do
  use UserApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug(UserApiWeb.Plugs.CreateSession)
  end

  pipeline :api_jwt do
    plug :accepts, ["json"]
    plug(UserApiWeb.Plugs.ParseJwt)
    plug(UserApiWeb.Plugs.CreateSession)
  end

  scope "/api", UserApiWeb do
    pipe_through :api_jwt 

    scope "/adventures" do
      get "/", AdventureController, :index
      get "/:id", AdventureController, :show
      get "/:id/ranking", RankingController, :index
      get "/:id/current_user_ranking", RankingController, :current_user_ranking
      get "/:adventure_id/completed_points", PointController, :completed_points
      post "/start", AdventureController, :start
      get "/summary/:id", AdventureController, :summary
    end

    scope "/clues" do
      get "/:adventure_id", ClueController, :index
      get "/point/:adventure_id/:point_id", ClueController, :list_for_point
    end

    scope "/points" do
      post "/resolve_point", PointController, :resolve_position_point
    end
    
  end

  scope "/api/auth", UserApiWeb do
    pipe_through :api 
    
    post "/", AuthController, :login
  end
  

  scope "/api/ping", UserApiWeb do
    pipe_through :api 
    
    get "/", PingController, :ping
  end

  # Other scopes may use custom stacks.
  # scope "/api", UserApiWeb do
  #   pipe_through :api
  # end
end
