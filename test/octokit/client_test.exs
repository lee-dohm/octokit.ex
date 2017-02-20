defmodule Octokit.Client.Test do
  use ExUnit.Case, async: false
  doctest Octokit.Client

  alias Octokit.Client
  alias Octokit.GitHub
  import Mock
  import Test.Helpers

  setup do
    {:ok, client: Client.new(id: "client_id", secret: "client_secret"),
          creds: %{client_id: "client_id", client_secret: "client_secret"},
          date: "2016-02-18T00:00:00Z"}
  end

  test "creating an unauthenticated client" do
    client = Client.new

    assert is_pid(client)
    assert is_nil(Client.last_response(client))
  end

  test "treat an empty list as an unauthenticated client" do
    client = Client.new([])

    assert is_pid(client)
    assert is_nil(Client.last_response(client))
  end

  test "creating a new client using id and secret" do
    client = Client.new(id: "client_id", secret: "client_secret")
    creds = Client.credentials(client)

    assert creds == %{client_id: "client_id", client_secret: "client_secret"}
    assert is_nil(Client.last_response(client))
  end

  test "creating a new client using a token" do
    client = Client.new(token: "token")
    creds = Client.credentials(client)

    assert creds == %{access_token: "token"}
    assert is_nil(Client.last_response(client))
  end

  test "creating a new client using a login and password" do
    client = Client.new(login: "username", password: "password")
    creds = Client.credentials(client)

    assert creds == %{login: "username", password: "password"}
    assert is_nil(Client.last_response(client))
  end

  test "creating a new client with invalid parameters" do
    assert_raise Client.InvalidCredentialsError, fn -> Client.new(foo: "bar") end
  end

  test "executing an API call sets the last_response", %{client: client, creds: creds} do
    with_github_mock :get, "user_response_valid" do
      Client.user(client, "lee-dohm")

      last_response = Client.last_response(client)

      assert called GitHub.get("/users/lee-dohm", [], params: creds)
      assert !is_nil(last_response)
      assert is_map(last_response)
      assert last_response.__struct__ == HTTPoison.Response
    end
  end

  test "executing a long API call sets the appropriate rels", %{client: client, date: date} do
    with_github_mock :get, "long_issues_list_valid" do
      Client.list_issues(client, "atom/atom", since: date)

      assert called GitHub.get("/repos/atom/atom/issues", [], params: %{
        client_id: "client_id",
        client_secret: "client_secret",
        since: date
      })

      assert Client.rels(client, :next) == "https://api.github.com/repositories/3228505/issues?since=2016-02-18T00%3A00%3A00Z&page=2"
      assert Client.rels(client, :last) == "https://api.github.com/repositories/3228505/issues?since=2016-02-18T00%3A00%3A00Z&page=2"
    end
  end

  test "asking for a rel that doesn't exist returns nil", %{client: client, date: date} do
    with_github_mock :get, "long_issues_list_valid" do
      Client.list_issues(client, "atom/atom", since: date)

      assert called GitHub.get("/repos/atom/atom/issues", [], params: %{
        client_id: "client_id",
        client_secret: "client_secret",
        since: date
      })

      assert is_nil(Client.rels(client, :prev))
    end
  end

  test "executing an API call sets the rate limit information", %{client: client, creds: creds} do
    with_github_mock :get, "issue_response_valid" do
      Client.issue(client, "atom/atom", 1234)

      assert called GitHub.get("/repos/atom/atom/issues/1234", [], params: creds)
      assert Client.rate_limit(client).limit == 60
      assert Client.rate_limit(client).remaining == 58
      assert Client.rate_limit(client).reset == 1455587834
    end
  end

  test "gets the rate limit information if no API call has been made", %{client: client} do
    with_github_mock :get, "rate_limit" do
      assert Client.rate_limit(client).limit == 5000
      assert Client.rate_limit(client).remaining == 5000
      assert Client.rate_limit(client).reset == 1456026238
    end
  end
end
