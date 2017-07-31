defmodule Feelingsmotron.Types do
  @moduledoc false

  # Ecto Schema Types
  @type user :: Feelingsmotron.User
  @type user_token :: Feelingsmotron.UserToken

  # Custom Types
  @type user_token_type :: :password_reset | :email_confirmation
end
