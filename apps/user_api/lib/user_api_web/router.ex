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

  scope "/auth", UserApiWeb do
    pipe_through :api 
    
    post "/", AuthController, :login
  end

  scope "/api", UserApiWeb do
    pipe_through :api_jwt 

    scope "/adventures" do
      get "/", AdventureController, :index
      get "/:id", AdventureController, :show
      get "/clues/:id", ClueController, :index
    end

    scope "/clues" do
      get "/:adventure_id", ClueController, :index
    end
    
  end

  # Other scopes may use custom stacks.
  # scope "/api", UserApiWeb do
  #   pipe_through :api
  # end
end
