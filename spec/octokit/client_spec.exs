defmodule Octokit.Client.Test do
  use ESpec, async: false
  doctest Octokit.Client

  alias Octokit.Client
  alias Octokit.GitHub
  import Spec.Helpers

  let :default_headers, do: [{"User-Agent", user_agent()}]
  let! :user_agent, do: Application.get_env(:octokit, :user_agent)

  describe "new" do
    describe "unauthenticated client" do
      subject do: Client.new

      it do: is_expected() |> to(be_pid())
      it do: expect subject() |> Client.last_response() |> to(be_nil())

      it "by passing an empty list" do
        client = Client.new([])

        expect client |> to(be_pid())
        expect client |> Client.last_response() |> to(be_nil())
      end
    end

    describe "client using application ID and secret" do
      subject do: Client.new(id: "client_id", secret: "client_secret")

      it do: is_expected() |> to(be_pid())
      it do: expect subject() |> Client.last_response() |> to(be_nil())

      it do
        expect subject()
               |> Client.credentials()
               |> to(eq %{client_id: "client_id", client_secret: "client_secret"})
      end
    end

    describe "client using a token" do
      subject do: Client.new(token: "token")

      it do: is_expected() |> to(be_pid())
      it do: expect subject() |> Client.last_response() |> to(be_nil())

      it do
        expect subject()
               |> Client.credentials()
               |> to(eq %{access_token: "token"})
      end
    end

    describe "client using a login and password" do
      subject do: Client.new(login: "login", password: "password")

      it do: is_expected() |> to(be_pid())
      it do: expect subject() |> Client.last_response() |> to(be_nil())

      it do
        expect subject()
               |> Client.credentials()
               |> to(eq %{login: "login", password: "password"})
      end
    end

    describe "client using invalid credentials" do
      it "raises an InvalidCredentialsError" do
        func = fn -> Client.new(foo: "bar") end

        expect func |> to(raise_exception Client.InvalidCredentialsError)
      end
    end
  end

  describe "when executing an API call with a valid response" do
    let :creds, do: %{client_id: "client_id", client_secret: "client_secret"}
    let :client, do: Client.new(id: "client_id", secret: "client_secret")
    let :last_response, do: Client.last_response(client())
    let :rate_limit, do: Client.rate_limit(client())

    before do
      allow GitHub |> to(accept :get, fn(_, _, _) -> {:ok, fixture("user_response_valid")} end)
      Client.user(client(), "lee-dohm")

      {:ok}
    end

    it do: expect last_response() |> to(be_struct HTTPoison.Response)
    it do: expect GitHub |> to(accepted :get, ["/users/lee-dohm", [], [params: creds()]])
    it do: expect rate_limit().limit |> to(eq 60)
    it do: expect rate_limit().remaining |> to(eq 59)
    it do: expect rate_limit().reset |> to(eq 1455607111)
  end

  describe "when executing an API call that returns a long response" do
    let :creds, do: %{client_id: "client_id", client_secret: "client_secret"}
    let :client, do: Client.new(id: "client_id", secret: "client_secret")
    let :date, do: "2016-02-18T00:00:00Z"
    let :last_response, do: Client.last_response(client())

    before do
      allow GitHub |> to(accept :get, fn(_, _, _) -> {:ok, fixture("long_issues_list_valid")} end)
      Client.list_issues(client(), "atom/atom", since: date())

      {:ok}
    end

    it do
      expect GitHub |> to(accepted :get, [
        "/repos/atom/atom/issues",
        [],
        [
          params: %{
            client_id: "client_id",
            client_secret: "client_secret",
            since: date()
          }
        ]
      ])
    end

    it "parses the rels values" do
      url = "https://api.github.com/repositories/" <>
            "3228505/issues?since=2016-02-18T00%3A00%3A00Z&page=2"

      expect client() |> Client.rels(:next) |> to(eq url)
      expect client() |> Client.rels(:last) |> to(eq url)
    end

    it "returns nil when asking for a rel that doesn't exist" do
      expect client() |> Client.rels(:prev) |> to(be_nil())
    end
  end

  describe "when no API call has been made" do
    let :client, do: Client.new(id: "client_id", secret: "client_secret")
    let :creds, do: %{client_id: "client_id", client_secret: "client_secret"}
    let :rate_limit, do: Client.rate_limit(client())

    before do: allow GitHub |> to(accept :get, fn(_, _, _) -> {:ok, fixture("rate_limit")} end)

    it "retrieves the rate limit information when it is requested" do
      expect rate_limit().limit |> to(eq 5000)
      expect rate_limit().remaining |> to(eq 5000)
      expect rate_limit().reset |> to(eq 1456026238)

      expect GitHub |> to(accepted :get, ["/rate_limit", [], [params: creds()]])
    end
  end
end
