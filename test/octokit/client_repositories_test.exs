defmodule Octokit.Client.Repositories.Test do
  use ExUnit.Case, async: false

  alias Octokit.Client
  alias Octokit.GitHub
  import Mock
  import Test.Helpers

  setup do
    {:ok, creds: %{client_id: "client_id", client_secret: "client_secret"}}
  end

  test "retrieve a repository with user/repo", %{creds: creds} do
    with_github_mock :get, "repository_response_atom" do
      client = Client.new(id: "client_id", secret: "client_secret")

      {:ok, repo} = Client.repository(client, "atom/atom")

      assert called GitHub.get("/repos/atom/atom", [], params: creds)
      assert repo.full_name == "atom/atom"
    end
  end

  test "retrieve a nonexistent repository" do
    with_github_mock :get, "repository_response_not_found" do
      client = Client.new(id: "client_id", secret: "client_secret")

      assert {:error, _} = Client.repository(client, "foo/bar")
    end
  end
end
