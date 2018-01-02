defmodule Feelingsmotron.Groups do
  @moduledoc """
  Contains methods for interacting with schemas related to groups that the user
  can be members of.
  """

  import Ecto.Query, warn: false
  alias Feelingsmotron.{Repo, Types}
  alias Feelingsmotron.Groups.Group
  alias Feelingsmotron.Groups.UserGroup
  alias Feelingsmotron.Account
  alias Feelingsmotron.Account.User

  @doc """
  Returns the group associated with the given id. If no group exists with that
  id, returns nil.
  """
  @spec get_group(integer()) :: Types.group | nil
  def get_group(id), do: Repo.get(Group, id)

  @spec list_all() :: [Types.group]
  def list_all do
    Group
    |> order_by(:name)
    |> Repo.all
  end

  @doc """
  Creates a group with the given user as the owner.

  If the user does not exist, returns an error tuple with an error changeset if
  the user does not exist or the name is invalid.
  """
  @spec create_group(String.t, Types.user | integer()) :: {:ok, Types.group} | {:error, Ecto.Changeset.t}
  def create_group(name, %User{} = owner), do: create_group(name, owner.id)
  def create_group(name, owner_id) do
    %Group{}
    |> Group.changeset(%{name: name, owner_id: owner_id})
    |> Repo.insert
  end

  @doc """
  Deletes a group if the given user is the owner of that group.

  If the user is not the owner of the group, returns the {:error, :forbidden}
  error tuple.

  If the user or group are not found, returns the {:error, :not_found} tuple.
  """
  @spec delete_group(Types.group | integer(), Types.user | integer()) :: {:ok, Types.group} | {:error, :forbidden | :not_found}
  def delete_group(group_id, deleting_user) when is_integer(group_id) do
    delete_group(get_group(group_id), deleting_user)
  end
  def delete_group(%Group{} = group, deleting_user_id) when is_integer(deleting_user_id) do
    delete_group(group, Account.get_user(deleting_user_id))
  end
  def delete_group(%Group{} = group, %User{} = deleting_user) do
    cond do
      group.owner_id != deleting_user.id ->
        {:error, :forbidden}
      true ->
        Repo.delete(group)
    end
  end
  def delete_group(nil, _user), do: {:error, :not_found}
  def delete_group(_group, nil), do: {:error, :not_found}

  @doc """
  Adds the user to the specified group.

  Returns an error tuple with an error changeset if the user or group don't
  exist or if the user is already in the group.
  """
  @spec add_user_to_group(Types.user | integer(), Types.group | integer()) :: {:ok, Types.user_group} | {:error, Ecto.Changeset.t}
  def add_user_to_group(%User{} = user, group_id), do: add_user_to_group(user.id, group_id)
  def add_user_to_group(user_id, %Group{} = group), do: add_user_to_group(user_id, group.id)
  def add_user_to_group(user_id, group_id) do
    %UserGroup{}
    |> UserGroup.changeset(%{user_id: user_id, group_id: group_id})
    |> Repo.insert
  end
end
