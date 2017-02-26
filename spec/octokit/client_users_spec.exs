defmodule Octokit.Client.Users.Spec do
  use ESpec, async: false

  alias Octokit.Client
  alias Octokit.GitHub
  import Spec.Helpers

  let :client, do: Client.new(id: "client_id", secret: "client_secret")
  let :creds, do: %{client_id: "client_id", client_secret: "client_secret"}

  describe "getting a user" do
    describe "by login" do
      before do: allow GitHub |> to(accept_get_and_return_fixture("user_response_valid"))

      it "returns a valid user record" do
        {:ok, user} = Client.user(client(), "lee-dohm")

        expect GitHub |> to(accepted :get, with_args("/users/lee-dohm", [], params: creds()))
        expect user.login |> to(eq "lee-dohm")
      end
    end

    describe "that does not exist" do
      before do: allow GitHub |> to(accept_get_and_return_fixture("user_response_invalid"))

      it "returns an error" do
        {status, _} = Client.user(client(), "foo")

        expect status |> to(eq :error)
      end
    end
  end
end
