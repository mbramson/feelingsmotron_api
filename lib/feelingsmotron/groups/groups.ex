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
  id, returns an error tuple of the format `{:error, :not_found}`.
  """
  @spec get_group(integer()) :: {:ok, Types.group} | {:error, :not_found}
  def get_group(id) do
    case Repo.get(Group, id) do
      nil -> {:error, :not_found}
      group -> {:ok, group}
    end
  end

  def get_group_with_users(id) do
    query = from group in Group,
      left_join: users in assoc(group, :users),
      left_join: owner in assoc(group, :owner),
      where: group.id == ^id,
      preload: [users: users, owner: owner]

    case query |> Repo.one do
      nil -> {:error, :not_found}
      group -> {:ok, group}
    end
  end

  @spec list_all() :: [Types.group]
  def list_all do
    Group
    |> order_by(:name)
    |> Repo.all
  end

  @doc """
  Creates a group with the given user as the owner.

  If the user does not exist, returns an error tuple with an error changeset if
  the user does not exist, the name is invalid, or the description is invalid.

  ## Examples

      iex> user_attrs = %{name: "fred", email: "email", password: "1234"}
      ...> {:ok, user} = Feelingsmotron.Account.create_user(user_attrs)
      ...> attrs = %{name: "fred's group", owner_id: user.id}
      ...> Feelingsmotron.Groups.create_group(attrs)
      {:ok, %Feelingsmotron.Groups.Group{}}

      iex> attrs = %{name: "george's group", owner_id: 999}
      ...> Feelingsmotron.Groups.create_group(attrs)
      {:error, Ecto.Changeset{}}
  """
  @spec create_group(map()) :: {:ok, Types.group} | {:error, Ecto.Changeset.t}
  def create_group(attrs) do
    %Group{}
    |> Group.changeset(attrs)
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
  def delete_group({:error, :not_found}, _user), do: {:error, :not_found}
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
