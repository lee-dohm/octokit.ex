defmodule Octokit.Client.Issues.Test do
  use ExUnit.Case, async: false

  alias Octokit.Client
  import Mock
  import Test.Helpers

  require Logger

  setup do
    {:ok, client: Client.new(id: "client_id", secret: "client_secret"),
          date: "2016-02-18T00:00:00Z"}
  end

  test "retrieve a valid issue", %{client: client} do
    with_mock HTTPoison, mock_get("issue_response_valid") do
      {:ok, issue} = Client.issue(client, "atom/atom", 1234)

      assert issue.number == 1234
      assert issue.state == "closed"
    end
  end

  test "attempt to retrieve an invalid issue", %{client: client} do
    with_mock HTTPoison, mock_get("issue_response_invalid") do
      assert {:error, _} = Client.issue(client, "foo/bar", 1234)
    end
  end

  test "retrieve a list of issues for a given repository", %{client: client} do
    with_mock HTTPoison, mock_get("issues_list_response_valid") do
      {:ok, issues_list} = Client.list_issues(client, "lee-dohm/tabs-to-spaces")

      assert Enum.count(issues_list) == 6
      assert Enum.all?(issues_list, fn(issue) -> is_map(issue) end)
      assert Enum.all?(issues_list, fn(issue) -> issue.__struct__ == Octokit.Issue end)
    end
  end

  test "attempt to retrieve issues from a nonexistent repo", %{client: client} do
    with_mock HTTPoison, mock_get("issues_list_response_invalid") do
      assert {:error, _} = Client.list_issues(client, "foo/bar")
    end
  end

  test "retrieve a list of issues for a repo updated since a certain date", %{client: client, date: date} do
    with_mock HTTPoison, mock_get("long_issues_list_valid") do
      {:ok, base_date} = Timex.DateFormat.parse(date, "{ISOz}")

      {:ok, issues_list} = Client.list_issues(client, "atom/atom", since: date)

      assert called HTTPoison.get(api_url("repos/atom/atom/issues",
                                          client_id: "client_id",
                                          client_secret: "client_secret",
                                          since: date))

      assert Enum.count(issues_list) == 30
      assert Enum.all?(issues_list, fn(issue) -> is_map(issue) end)
      assert Enum.all?(issues_list, fn(issue) -> issue.__struct__ == Octokit.Issue end)

      assert Enum.all?(issues_list, fn(issue) ->
        {:ok, updated_date} = Timex.DateFormat.parse(issue.updated_at, "{ISOz}")
        Timex.Date.compare(base_date, updated_date) <= 0
      end)
    end
  end

  test "retrieve a list of issues for an org", %{client: client} do
    with_mock HTTPoison, mock_get("issues_list_response_valid") do
      {:ok, issues_list} = Client.list_issues(client, "lee-dohm")

      assert called HTTPoison.get(api_url("orgs/lee-dohm/issues"))
      assert Enum.count(issues_list) == 6
      assert Enum.all?(issues_list, fn(issue) -> is_map(issue) end)
      assert Enum.all?(issues_list, fn(issue) -> issue.__struct__ == Octokit.Issue end)
    end
  end
end
