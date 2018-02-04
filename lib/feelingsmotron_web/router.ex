defmodule FeelingsmotronWeb.Router do
  use FeelingsmotronWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
    plug Guardian.Plug.EnsureResource
  end

  scope "/api", FeelingsmotronWeb do
    pipe_through :api

    scope "/v1" do
      post "/registrations", RegistrationController, :create
      post "/sessions", SessionController, :create
      post "/password_reset", PasswordResetController, :create
      get "/password_reset", PasswordResetController, :show
      put "/password_reset", PasswordResetController, :update
    end

    scope "/v1" do
      pipe_through :api_auth

      get "/profile", ProfileController, :show
      put "/profile", ProfileController, :update

      get "/feelings", FeelingsController, :show
      post "/feelings", FeelingsController, :create

      resources "/groups", GroupController, except: [:new, :edit]

      resources "/group_invitations", GroupInvitationController, except: [:new, :show, :edit]
    end
  end
end
