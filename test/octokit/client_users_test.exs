defmodule Octokit.Client.Users.Test do
  use ExUnit.Case, async: false

  alias Octokit.Client
  import Mock
  import Test.Helpers

  test "retrieve a user by login" do
    with_mock HTTPoison, mock_get("user_response_valid") do
      client = Client.new(id: "client_id", secret: "client_secret")

      {:ok, user} = Client.user(client, "lee-dohm")

      assert called HTTPoison.get(api_url("users/lee-dohm",
                                          client_id: "client_id",
                                          client_secret: "client_secret"))

      assert user.login == "lee-dohm"
    end
  end

  test "retrieve a nonexistent user" do
    with_mock HTTPoison, mock_get("user_response_invalid") do
      client = Client.new(id: "client_id", secret: "client_secret")

      assert {:error, _} = Client.user(client, "foo")
    end
  end
end
