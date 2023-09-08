defmodule Rumbl.AccountsTest do
  use Rumbl.DataCase, async: true

  alias Rumbl.Accounts
  alias Rumbl.Accounts.User

  describe "list_users/0" do
    test "should returns all users, return two users if two users exists" do
      user_1 = %{
        name: "User",
        username: "eva",
        password: "secret"
      }

      user_2 = %{
        name: "User2",
        username: "eva2",
        password: "secret2"
      }

      {:ok, %User{id: id_1}} = Accounts.register_user(user_1)
      {:ok, %User{id: id_2}} = Accounts.register_user(user_2)
      assert [%User{id: ^id_1}, %User{id: ^id_2}] = Accounts.list_users()
    end

    test "should returns all users, return empty if no users exists" do
      assert [] = Accounts.list_users()
    end
  end

  describe "get_user/1" do
    test "should returns user by id, if exists" do
      user_1 = %{
        name: "User",
        username: "eva",
        password: "secret"
      }

      {:ok, %User{id: id_1}} = Accounts.register_user(user_1)
      assert %User{id: ^id_1} = Accounts.get_user(id_1)
    end
  end

  describe "get_user!/1" do
    test "should returns user by id, if exists" do
      user_1 = %{
        name: "User",
        username: "eva",
        password: "secret"
      }

      {:ok, %User{id: id_1}} = Accounts.register_user(user_1)
      assert %User{id: ^id_1} = Accounts.get_user!(id_1)
    end
  end

  describe "get_user_by/1" do
    test "should returns user by params, if exists" do
      user_1 = %{
        name: "User",
        username: "eva",
        password: "secret"
      }

      {:ok, %User{id: id_1}} = Accounts.register_user(user_1)
      assert %User{id: ^id_1} = Accounts.get_user_by(username: "eva")
    end
  end

  describe "register_user/1" do
    @valid_attrs %{
      name: "User",
      username: "eva",
      password: "secret"
    }

    @invalid_attrs %{}

    test "With valid data insert user" do
      assert {:ok, %User{id: id} = user} = Accounts.register_user(@valid_attrs)
      assert user.name == @valid_attrs.name
      assert user.username == @valid_attrs.username
      assert [%User{id: ^id}] = Accounts.list_users()
    end

    test "with invalid data does not insert user" do
      assert {:error, changeset} = Accounts.register_user(@invalid_attrs)
      assert Accounts.list_users() == []

      assert %{
               username: ["can't be blank"],
               name: ["can't be blank"],
               password: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "enforces unique usernames" do
      assert {:ok, %User{id: id}} = Accounts.register_user(@valid_attrs)
      assert {:error, changeset} = Accounts.register_user(@valid_attrs)

      assert %{username: ["has already been taken"]} = errors_on(changeset)

      assert [%User{id: ^id}] = Accounts.list_users()
    end

    test "does not accept long usernames" do
      attrs = Map.put(@valid_attrs, :username, String.duplicate("a", 30))
      {:error, changeset} = Accounts.register_user(attrs)

      assert %{username: ["should be at most 20 character(s)"]} = errors_on(changeset)

      assert Accounts.list_users() == []
    end

    test "requires password to be at least 6 chars long" do
      attrs = Map.put(@valid_attrs, :password, "12345")
      {:error, changeset} = Accounts.register_user(attrs)

      assert %{password: ["should be at least 6 character(s)"]} = errors_on(changeset)

      assert Accounts.list_users() == []
    end
  end

  describe "authenticate_by_username_and_password/2" do
    @password "123456"

    setup do
      {:ok, user: user_fixture(password: @password)}
    end

    test "returns user with correct password", %{user: user} do
      assert {:ok, auth_user} =
               Accounts.authenticate_by_username_and_password(user.username, @password)

      assert auth_user.id == user.id
    end

    test "returns unauthorized error with invalid password", %{user: user} do
      assert {:error, :unauthorized} =
               Accounts.authenticate_by_username_and_password(user.username, "bad_password")
    end

    test "returns not found error with no matching user for username" do
      assert {:error, :not_found} =
               Accounts.authenticate_by_username_and_password("unknown_user", @password)
    end
  end
end
