defmodule Feelingsmotron.Feelings do
  @moduledoc """
  The Feelings context.
  """

  import Ecto.Query, warn: false
  alias Feelingsmotron.Repo

  alias Feelingsmotron.Feelings.Feeling
  alias Feelingsmotron.Feelings.Comment

  @doc """
  Returns the list of feelings.

  ## Examples

      iex> list_feelings()
      [%Feeling{}, ...]

  """
  def list_feelings do
    Repo.all(Feeling)
  end

  @doc """
  Gets a single feeling.

  Raises `Ecto.NoResultsError` if the Feeling does not exist.

  ## Examples

      iex> get_feeling!(123)
      %Feeling{}

      iex> get_feeling!(456)
      ** (Ecto.NoResultsError)

  """
  def get_feeling!(id), do: Repo.get!(Feeling, id)

  @doc """
  Creates a feeling.

  ## Examples

      iex> create_feeling(%{field: value})
      {:ok, %Feeling{}}

      iex> create_feeling(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_feeling(attrs \\ %{}) do
    %Feeling{}
    |> Feeling.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a feeling.

  ## Examples

      iex> update_feeling(feeling, %{field: new_value})
      {:ok, %Feeling{}}

      iex> update_feeling(feeling, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_feeling(%Feeling{} = feeling, attrs) do
    feeling
    |> Feeling.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Feeling.

  ## Examples

      iex> delete_feeling(feeling)
      {:ok, %Feeling{}}

      iex> delete_feeling(feeling)
      {:error, %Ecto.Changeset{}}

  """
  def delete_feeling(%Feeling{} = feeling) do
    Repo.delete(feeling)
  end

  @doc """
  Returns the last feeling created for the given user.
  """
  def last_feeling(user) do
    query = from f in Feeling,
      where: f.user_id == ^user.id,
      order_by: [desc: f.inserted_at],
      limit: 1
    Repo.one(query)
  end

  @doc """
  Creates a Comment which should be associated with a specific feeling entry.
  """
  def create_comment(attrs) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a Feeling with an associated Comment. Uses a transaction for all
  database operations. The returned feeling struct does not have the comment
  preloaded.
  """
  @spec create_feeling_with_comment(integer(), integer(), String.t) :: {:ok, %Feeling{}} | {:error, Ecto.Changeset.t | :unhandled}
  def create_feeling_with_comment(user_id, value, comment_text) do
    case create_feeling_with_comment_transaction(user_id, value, comment_text) do
      {:ok, {:ok, feeling}} -> {:ok, feeling}
      error -> error
    end
  end

  @spec create_feeling_with_comment_transaction(integer(), integer(), String.t) :: {:ok, {:ok, %Feeling{}}} | {:error, Ecto.Changeset.t | :unhandled}
  defp create_feeling_with_comment_transaction(user_id, value, comment_text) do
    Repo.transaction(fn ->
      with {:ok, comment} <- create_comment(%{text: comment_text}),
           {:ok, feeling} <- create_feeling(%{user_id: user_id, value: value, comment_id: comment.id}) do
        {:ok, feeling}
      else
        {:error, changeset} -> Repo.rollback(changeset)
        _ -> Repo.rollback(:unhandled)
      end
    end)
  end
end
