defmodule Octokit.Client.Users.Test do
  use ExUnit.Case, async: false

  alias Octokit.Client
  alias Octokit.GitHub
  import Mock
  import Test.Helpers

  setup do
    {:ok, creds: %{client_id: "client_id", client_secret: "client_secret"}}
  end

  test "retrieve a user by login", %{creds: creds} do
    with_github_mock :get, "user_response_valid" do
      client = Client.new(id: "client_id", secret: "client_secret")

      {:ok, user} = Client.user(client, "lee-dohm")

      assert called GitHub.get("/users/lee-dohm", [], params: creds)
      assert user.login == "lee-dohm"
    end
  end

  test "retrieve a nonexistent user" do
    with_github_mock :get, "user_response_invalid" do
      client = Client.new(id: "client_id", secret: "client_secret")

      assert {:error, _} = Client.user(client, "foo")
    end
  end
end
