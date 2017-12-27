defmodule Feelingsmotron.FeelingsTest do
  use Feelingsmotron.DataCase

  alias Feelingsmotron.Feelings

  describe "feelings" do
    alias Feelingsmotron.Feelings.Feeling

    @valid_attrs %{value: 3}
    @update_attrs %{value: 4}
    @invalid_attrs %{value: nil}

    def feeling_fixture(attrs \\ %{}) do
      user = insert(:user)
      attrs = Map.merge(attrs, %{user_id: user.id})
      {:ok, feeling} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Feelings.create_feeling()

      feeling
    end

    test "list_feelings/0 returns all feelings" do
      feeling = feeling_fixture()
      assert Feelings.list_feelings() == [feeling]
    end

    test "get_feeling!/1 returns the feeling with given id" do
      feeling = feeling_fixture()
      assert Feelings.get_feeling!(feeling.id) == feeling
    end

    test "create_feeling/1 with valid data creates a feeling" do
      user = insert(:user)
      attrs = Map.merge(@valid_attrs, %{user_id: user.id})

      assert {:ok, %Feeling{} = feeling} = Feelings.create_feeling(attrs)
      assert feeling.value == 3
      assert feeling.user_id == user.id
    end

    test "create_feeling/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Feelings.create_feeling(@invalid_attrs)
    end

    test "create_feeling/1 with a non-existant user errors" do
      attrs = Map.merge(@valid_attrs, %{user_id: 999})
      assert {:error, _} = Feelings.create_feeling(attrs)
    end

    test "create_feeling/1 with invalid feeling values returns error changeset" do
      user = insert(:user)

      invalid_attrs = %{value: 0, user_id: user.id}
      assert {:error, %Ecto.Changeset{}} = Feelings.create_feeling(invalid_attrs)

      invalid_attrs = %{value: 6, user_id: user.id}
      assert {:error, %Ecto.Changeset{}} = Feelings.create_feeling(invalid_attrs)

      invalid_attrs = %{value: "cats", user_id: user.id}
      assert {:error, %Ecto.Changeset{}} = Feelings.create_feeling(invalid_attrs)
    end

    test "update_feeling/2 with valid data updates the feeling" do
      feeling = feeling_fixture()
      assert {:ok, feeling} = Feelings.update_feeling(feeling, @update_attrs)
      assert %Feeling{} = feeling
      assert feeling.value == 4
    end

    test "update_feeling/2 with invalid data returns error changeset" do
      feeling = feeling_fixture()
      assert {:error, %Ecto.Changeset{}} = Feelings.update_feeling(feeling, @invalid_attrs)
      assert feeling == Feelings.get_feeling!(feeling.id)
    end

    test "delete_feeling/1 deletes the feeling" do
      feeling = feeling_fixture()
      assert {:ok, %Feeling{}} = Feelings.delete_feeling(feeling)
      assert_raise Ecto.NoResultsError, fn -> Feelings.get_feeling!(feeling.id) end
    end

    test "last_feeling/1 returns nil if there was no previous feeling" do
      user = insert(:user)
      assert nil == Feelings.last_feeling(user)
    end

    test "last_feeling/1 returns a feeling if it exists" do
      user = insert(:user)
      feeling = insert(:feeling, %{user: user})
      returned_feeling = Feelings.last_feeling(user)
      assert feeling.id == returned_feeling.id
    end

    test "last_feeling/1 returns only the last feeling to be inserted" do
      user = insert(:user)
      insert(:feeling, %{user: user})
      feeling2 = insert(:feeling, %{user: user})
      returned_feeling = Feelings.last_feeling(user)
      assert feeling2.id == returned_feeling.id
    end
  end

  describe "create_comment/1" do
    test "creates a comment" do
      assert {:ok, comment} = Feelings.create_comment(%{text: "super happy"})
      assert comment.text == "super happy"
    end
  end

  describe "create_feeling_with_comment/3" do
    test "inserts feeling and associated comment into the database" do
      user = insert(:user)
      assert {:ok, feeling} = Feelings.create_feeling_with_comment(user.id, 3, "very happy")
      assert Repo.all(Feelings.Feeling) |> length == 1
      assert feeling.value == 3

      assert Repo.all(Feelings.Comment) |> length == 1
      feeling = feeling |> Repo.preload(:comment)
      assert feeling.comment.text == "very happy"
    end

    test "fails when the user_id is not associated with a user" do
      assert {:error, _changeset} = Feelings.create_feeling_with_comment(999, 3, "very happy")
    end

    test "rolls back the comment insertion if the feeling insertion fails" do
      Feelings.create_feeling_with_comment(999, 3, "very happy")
      assert Repo.all(Feelings.Comment) |> length == 0
    end
  end
end
