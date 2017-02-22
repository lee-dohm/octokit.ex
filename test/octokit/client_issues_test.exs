defmodule Octokit.Client.Issues.Test do
  use ExUnit.Case, async: false

  alias Octokit.Client
  alias Octokit.GitHub
  alias Timex.Parse.DateTime.Parser, as: TimexParser
  import Mock
  import Test.Helpers

  require Logger

  setup do
    {:ok, client: Client.new(id: "client_id", secret: "client_secret"),
          creds: %{client_id: "client_id", client_secret: "client_secret"},
          date: "2016-02-18T00:00:00Z"}
  end

  test "retrieve a valid issue", %{client: client, creds: creds} do
    with_github_mock :get, "issue_response_valid" do
      {:ok, issue} = Client.issue(client, "atom/atom", 1234)

      assert called GitHub.get("/repos/atom/atom/issues/1234", [], params: creds)
      assert issue.number == 1234
      assert issue.state == "closed"
    end
  end

  test "attempt to retrieve an invalid issue", %{client: client, creds: creds} do
    with_github_mock :get, "issue_response_invalid" do
      assert {:error, _} = Client.issue(client, "foo/bar", 1234)
      assert called GitHub.get("/repos/foo/bar/issues/1234", [], params: creds)
    end
  end

  test "retrieve a list of issues for a given repository", %{client: client, creds: creds} do
    with_github_mock :get, "issues_list_response_valid" do
      {:ok, issues_list} = Client.list_issues(client, "lee-dohm/tabs-to-spaces")

      assert called GitHub.get("/repos/lee-dohm/tabs-to-spaces/issues", [], params: creds)
      assert Enum.count(issues_list) == 6
      assert Enum.all?(issues_list, fn(issue) -> is_map(issue) end)
      assert Enum.all?(issues_list, fn(issue) -> issue.__struct__ == Octokit.Issue end)
    end
  end

  test "attempt to retrieve issues from a nonexistent repo", %{client: client, creds: creds} do
    with_github_mock :get, "issues_list_response_invalid" do
      assert {:error, _} = Client.list_issues(client, "foo/bar")
      assert called GitHub.get("/repos/foo/bar/issues", [], params: creds)
    end
  end

  test "retrieve a list of issues for a repo updated since a certain date",
       %{client: client, date: date} do
    with_github_mock :get, "long_issues_list_valid" do
      {:ok, base_date} = TimexParser.parse(date, "{ISO:Extended:Z}")

      {:ok, issues_list} = Client.list_issues(client, "atom/atom", since: date)

      assert called GitHub.get("/repos/atom/atom/issues",
                                  [],
                                  params: %{
                                    client_id: "client_id",
                                    client_secret: "client_secret",
                                    since: date
                                  })

      assert Enum.count(issues_list) == 30
      assert Enum.all?(issues_list, fn(issue) -> is_map(issue) end)
      assert Enum.all?(issues_list, fn(issue) -> issue.__struct__ == Octokit.Issue end)

      assert Enum.all?(issues_list, fn(issue) ->
        {:ok, updated_date} = TimexParser.parse(issue.updated_at, "{ISO:Extended:Z}")
        Timex.compare(base_date, updated_date) <= 0
      end)
    end
  end

  test "retrieve a list of issues for an org", %{client: client, creds: creds} do
    with_github_mock :get, "issues_list_response_valid" do
      {:ok, issues_list} = Client.list_issues(client, "lee-dohm")

      assert called GitHub.get("/orgs/lee-dohm/issues", [], params: creds)
      assert Enum.count(issues_list) == 6
      assert Enum.all?(issues_list, fn(issue) -> is_map(issue) end)
      assert Enum.all?(issues_list, fn(issue) -> issue.__struct__ == Octokit.Issue end)
    end
  end

  test "get the next page of issues for an org", %{client: client} do
    with_github_mock [
      get: fn("https://api.github.com/orgs/lee-dohm/issues",
              [],
              [params: %{page: 2, client_id: "client_id", client_secret: "client_secret"}]) ->
                {:ok, fixture("long_issues_list_valid")}
              end,
      get: fn(_, _, _) -> {:ok, fixture("long_issues_list_valid")} end
    ] do
      {:ok, _} = Client.list_issues(client, "lee-dohm")
      url = Client.rels(client, :next)
      {:ok, issues} = Client.list_issues(client, :next)

      assert called GitHub.get(url, [], [])

      assert Enum.count(issues) == 30
      assert Enum.all?(issues, fn(issue) -> is_map(issue) end)
      assert Enum.all?(issues, fn(issue) -> issue.__struct__ == Octokit.Issue end)
    end
  end
end
