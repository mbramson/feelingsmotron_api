defmodule Feelingsmotron.Groups do
  @moduledoc """
  Contains methods for interacting with schemas related to groups that the user
  can be members of.
  """

  import Ecto.Query, warn: false
  alias Feelingsmotron.{Repo, Types}
  alias Feelingsmotron.Groups.Group
  alias Feelingsmotron.Groups.UserGroup
  alias Feelingsmotron.Account.User

  @spec list_groups() :: [Types.group]
  def list_groups do
    Repo.all(Group)
  end

  @spec create_group(String.t, Types.user | integer()) :: {:ok, Types.group} | {:error, Ecto.Changeset.t}
  def create_group(name, %User{} = owner), do: create_group(name, owner.id)
  def create_group(name, owner_id) when is_binary(name) and is_integer(owner_id) do
    %Group{}
    |> Group.changeset(%{name: name, owner_id: owner_id})
    |> Repo.insert
  end
end
