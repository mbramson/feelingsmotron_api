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

      get "/groups", GroupController, :index
      get "/groups/:id", GroupController, :show
      post "/groups", GroupController, :create
      put "/groups/:id", GroupController, :update
      delete "/groups/:id", GroupController, :delete

      get "/group_invitations", GroupInvitationController, :index
      post "/group_invitations", GroupInvitationController, :create
      put "/group_invitations/:id", GroupInvitationController, :update
      delete "/group_invitations/:id", GroupInvitationController, :delete
    end
  end
end
