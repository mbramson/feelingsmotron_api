defmodule Feelingsmotron.Types do
  @moduledoc false

  # Ecto Schema Types
  @type user :: Feelingsmotron.Account.User
  @type user_token :: Feelingsmotron.Account.UserToken
  @type group :: Feelingsmotron.Groups.Group
  @type user_group :: Feelingsmotron.Groups.UserGroup
  @type group_invitation :: Feelingsmotron.Groups.Invitation
end
