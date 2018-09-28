defmodule UserApiWeb.Router do
  use UserApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug(UserApiWeb.Plugs.CreateSession)
  end

  scope "/auth", UserApiWeb do
    pipe_through :api 
    
    post "/", AuthController, :login
  end

  scope "/api", UserApiWeb do
    pipe_through :api 

    scope "adventures" do
      get "/", AdventureController, :index
    end
    
  end

  # Other scopes may use custom stacks.
  # scope "/api", UserApiWeb do
  #   pipe_through :api
  # end
end
