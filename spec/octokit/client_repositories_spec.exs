defmodule Octokit.Client.Repositories.Spec do
  use ESpec, async: false

  alias Octokit.Client
  alias Octokit.GitHub
  import Spec.Helpers

  let :client, do: Client.new(id: "client_id", secret: "client_secret")
  let :creds, do: %{client_id: "client_id", client_secret: "client_secret"}

  describe "getting a repository with user/repo" do
    before do: allow GitHub |> to(accept_get_and_return_fixture("repository_response_atom"))

    let_ok :repo, do: Client.repository(client(), "atom/atom")

    it do: expect repo().full_name |> to(eq "atom/atom")

    it do
      repo()

      expect GitHub |> to(accepted :get, with_args("/repos/atom/atom", [], params: creds()))
    end
  end

  describe "getting a nonexistent repository" do
    before do: allow GitHub |> to(accept_get_and_return_fixture("repository_response_not_found"))

    it "returns an error" do
      {status, _} = Client.repository(client(), "foo/bar")

      expect status |> to(eq :error)
    end
  end
end
