defmodule Feelingsmotron.Factory do
  use ExMachina.Ecto, repo: Feelingsmotron.Repo

  def user_factory do
    %Feelingsmotron.Account.User{
      name: sequence(:name, &"user-#{&1}"),
      email: sequence(:email, &"email-#{&1}@example.com"),
      password_hash: "password_hash",
    }
  end

  def user_token_factory do
    %Feelingsmotron.Account.UserToken{
      token: sequence(:token_string, &"user-token-string-#{&1}"),
      type: "password_reset",
      user: build(:user),
    }
  end

  def feeling_factory do
    %Feelingsmotron.Feelings.Feeling{
      value: 1,
      user: build(:user),
    }
  end

  def group_factory do
    %Feelingsmotron.Groups.Group{
      name: sequence(:name, &"group-#{&1}"),
      owner: build(:user),
      users: [],
    }
  end

  def user_group_factory do
    %Feelingsmotron.Groups.UserGroup{
      user: build(:user),
      group: build(:group),
    }
  end

  def group_invitation_factory do
    %Feelingsmotron.Groups.Invitation{
      user: build(:user),
      group: build(:group),
      from_group: true,
    }
  end
end
