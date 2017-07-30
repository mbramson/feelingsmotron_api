defmodule Feelingsmotron.Factory do
  use ExMachina.Ecto, repo: Feelingsmotron.Repo

  def user_factory do
    %Feelingsmotron.Account.User{
      name: sequence(:name, &"user-#{&1}"),
      email: sequence(:email, &"email-#{&1}@example.com"),
      password_hash: "password_hash"
    }
  end

  def user_token_factory do
    %Feelingsmotron.Account.UserToken{
      token: sequence(:token_string, &"user-token-string-#{&1}"),
      type: 'confirmation',
      user: build(:user)
    }
  end
end
