defmodule Feelingsmotron.Account.UserToken do
  use Ecto.Schema
  import Ecto.Changeset
  alias Feelingsmotron.Account.UserToken

  schema "user_tokens" do
    belongs_to :user, Feelingsmotron.Account.User
    field :token, :string
    field :type, :string

    timestamps()
  end

  @all_fields ~w(user_id token type)a

  @doc false
  def changeset(%UserToken{} = user, attrs) do
    user
    |> cast(attrs, @all_fields)
    |> validate_required(@all_fields)
  end
end
