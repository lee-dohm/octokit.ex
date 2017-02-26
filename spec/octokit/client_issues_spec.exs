defmodule Octokit.Client.Issues.Spec do
  use ESpec, async: false

  alias Octokit.Client
  alias Octokit.GitHub
  alias Octokit.Issue
  alias Timex.Parse.DateTime.Parser, as: TimexParser
  import Spec.Helpers

  let :client, do: Client.new(id: "client_id", secret: "client_secret")
  let :creds, do: %{client_id: "client_id", client_secret: "client_secret"}
  let :date, do: "2016-02-18T00:00:00Z"

  describe "getting a valid Issue" do
    before do
      allow GitHub |> to(accept_get_and_return_fixture("issue_response_valid"))
      {:ok, issue} = Client.issue(client(), "atom/atom", 1234)

      {:ok, issue: issue}
    end

    it do
      expect GitHub
             |> to(accepted :get, with_args("/repos/atom/atom/issues/1234", [], params: creds()))
    end

    it do: expect shared.issue.number |> to(eq 1234)
    it do: expect shared.issue.state |> to(eq "closed")
  end

  describe "getting an invalid Issue" do
    before do: allow GitHub |> to(accept_get_and_return_fixture("issue_response_invalid"))

    it "returns an error" do
      {status, _} = Client.issue(client(), "foo/bar", 1234)

      expect status |> to(eq :error)
      expect GitHub
             |> to(accepted :get, with_args("/repos/foo/bar/issues/1234", [], params: creds()))
    end
  end

  describe "getting a list of issues from a repository" do
    before do: allow GitHub |> to(accept_get_and_return_fixture("issues_list_response_valid"))

    let_ok :issues_list, do: Client.list_issues(client(), "lee-dohm/tabs-to-spaces")

    it do: expect issues_list() |> to(have_count 6)
    it do: expect issues_list() |> to(have_all_struct Issue)

    it do
      issues_list()

      expect GitHub
             |> to(accepted :get,
                   with_args("/repos/lee-dohm/tabs-to-spaces/issues", [], params: creds()))
    end
  end

  describe "getting a list of issues from a nonexistent repository" do
    before do: allow GitHub |> to(accept_get_and_return_fixture("issues_list_response_invalid"))

    it "returns an error" do
      {:error, _} = Client.list_issues(client(), "foo/bar")

      expect GitHub |> to(accepted :get, with_args("/repos/foo/bar/issues", [], params: creds()))
    end
  end

  describe "getting a list of issues for a repo since a certain date" do
    before do: allow GitHub |> to(accept_get_and_return_fixture("long_issues_list_valid"))

    let_ok :base_date, do: TimexParser.parse(date(), "{ISO:Extended:Z}")
    let_ok :issues_list, do: Client.list_issues(client(), "atom/atom", since: date())

    it do: expect issues_list() |> to(have_count 30)
    it do: expect issues_list() |> to(have_all_struct Issue)

    it do
      expect issues_list() |> to(have_all fn(issue) ->
        {:ok, updated_date} = TimexParser.parse(issue.updated_at, "{ISO:Extended:Z}")
        Timex.compare(base_date(), updated_date) <= 0
      end)
    end

    it do
      issues_list()

      expect GitHub
             |> to(
                  accepted :get,
                  with_args(
                    "/repos/atom/atom/issues",
                    [],
                    params: Map.merge(creds(), %{since: date()})))
    end
  end

  describe "getting a list of issues for an org" do
    before do: allow GitHub |> to(accept_get_and_return_fixture("issues_list_response_valid"))

    let_ok :issues_list, do: Client.list_issues(client(), "lee-dohm")

    it do: expect issues_list() |> to(have_count 6)
    it do: expect issues_list() |> to(have_all_struct Issue)

    it do
      issues_list()

      expect GitHub |> to(accepted :get, with_args("/orgs/lee-dohm/issues", [], params: creds()))
    end
  end

  describe "get the next page of issues for an org" do
    before do
      allow GitHub |> to(accept_get_and_return_fixture("long_issues_list_valid"))
      {:ok, _} = Client.list_issues(client(), "lee-dohm")
      url = Client.rels(client(), :next)
      {:ok, issues} = Client.list_issues(client(), :next)

      {:ok, issues: issues, url: url}
    end

    it do: expect GitHub |> to(accepted :get, with_args(shared.url, [], []))
    it do: expect shared.issues |> to(have_count 30)
    it do: expect shared.issues |> to(have_all_struct Issue)
  end
end
