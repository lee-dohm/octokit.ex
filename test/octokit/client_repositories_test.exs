defmodule Octokit.Client.Repositories.Test do
  use ExUnit.Case, async: false

  alias Octokit.Client
  import Mock
  import Test.Helpers

  test "retrieve a repository with user/repo" do
    with_mock HTTPoison, mock_get("repository_response_atom") do
      client = Client.new(id: "client_id", secret: "client_secret")

      {:ok, repo} = Client.repository(client, "atom/atom")

      assert repo.full_name == "atom/atom"
    end
  end

  test "retrieve a nonexistent repository" do
    with_mock HTTPoison, mock_get("repository_response_not_found") do
      client = Client.new(id: "client_id", secret: "client_secret")

      assert {:error, _} = Client.repository(client, "foo/bar")
    end
  end
end
