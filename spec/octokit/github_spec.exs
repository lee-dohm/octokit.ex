defmodule Octokit.GitHub.Spec do
  use ESpec, async: false
  doctest Octokit.GitHub

  alias Octokit.GitHub

  let :default_headers, do: [{"User-Agent", user_agent()}]
  let! :user_agent, do: Application.get_env(:octokit, :user_agent)

  finally do: Application.put_env(:octokit, :user_agent, user_agent())

  describe "get" do
    before do: allow HTTPoison |> to(accept :get, fn(_, _, _) -> nil end)

    it "prepends the GitHub API location" do
      GitHub.get("/test")

      expect HTTPoison |> to(accepted :get, ["https://api.github.com/test", default_headers(), []])
    end

    it "doesn't prepend the API location if it is already there" do
      GitHub.get("https://api.github.com/test")

      expect HTTPoison |> to(accepted :get, ["https://api.github.com/test", default_headers(), []])
    end

    it "uses token credentials as query parameters" do
      GitHub.get("/test", [], creds: %{token: "access_token"})

      expect HTTPoison |> to(accepted :get, [
        "https://api.github.com/test",
        default_headers(),
        [params: %{token: "access_token"}]
      ])
    end

    it "adds token credentials as query parameters" do
      GitHub.get("/test", [], creds: %{token: "access_token"}, params: %{foo: "bar"})

      expect HTTPoison |> to(accepted :get, [
        "https://api.github.com/test",
        default_headers(),
        [params: %{foo: "bar", token: "access_token"}]
      ])
    end

    it "uses application credentials as query parameters" do
      GitHub.get("/test", [], creds: %{client_id: "client_id", client_secret: "client_secret"})

      expect HTTPoison |> to(accepted :get, [
        "https://api.github.com/test",
        default_headers(),
        [params: %{client_id: "client_id", client_secret: "client_secret"}]
      ])
    end

    it "adds application credentials to query parameters" do
      GitHub.get(
        "/test",
        [],
        creds: %{client_id: "client_id", client_secret: "client_secret"},
        params: %{foo: "bar"}
      )

      expect HTTPoison |> to(accepted :get, [
        "https://api.github.com/test",
        default_headers(),
        [params: %{
          client_id: "client_id",
          client_secret: "client_secret",
          foo: "bar"
        }]
      ])
    end

    it "adds a basic authentication header when supplied login credentials" do
      GitHub.get("/test", [], creds: %{login: "login", password: "password"})

      expect HTTPoison |> to(accepted :get, [
        "https://api.github.com/test",
        [
          {"User-Agent", user_agent()},
          {"Authorization", "Basic bG9naW46cGFzc3dvcmQ="}
        ],
        []
      ])
    end

    it "doesn't overwrite a user-supplied User-Agent header" do
      GitHub.get("/test", [{"User-Agent", "Testy testy test!"}], [])

      expect HTTPoison |> to(accepted :get, [
        "https://api.github.com/test",
        [{"User-Agent", "Testy testy test!"}],
        []
      ])
    end

    it "uses the user agent from the application configuration" do
      Application.put_env(:octokit, :user_agent, "Testing!")
      GitHub.get("/test")

      expect HTTPoison |> to(accepted :get, [
        "https://api.github.com/test",
        [{"User-Agent", "Testing!"}],
        []
      ])
    end
  end

  describe "post" do
    before do: allow HTTPoison |> to(accept :post, fn(_, _, _, _) -> nil end)

    it "prepends the GitHub API location" do
      GitHub.post("/test", "")

      expect HTTPoison |> to(accepted :post, ["https://api.github.com/test", "", default_headers(), []])
    end

    it "doesn't prepend the API location if it is already there" do
      GitHub.post("https://api.github.com/test", "")

      expect HTTPoison |> to(accepted :post, ["https://api.github.com/test", "", default_headers(), []])
    end

    it "uses token credentials as query parameters" do
      GitHub.post("/test", "", [], creds: %{token: "access_token"})

      expect HTTPoison |> to(accepted :post, [
        "https://api.github.com/test",
        "",
        default_headers(),
        [params: %{token: "access_token"}]
      ])
    end

    it "adds token credentials as query parameters" do
      GitHub.post("/test", "", [], creds: %{token: "access_token"}, params: %{foo: "bar"})

      expect HTTPoison |> to(accepted :post, [
        "https://api.github.com/test",
        "",
        default_headers(),
        [params: %{foo: "bar", token: "access_token"}]
      ])
    end

    it "uses application credentials as query parameters" do
      GitHub.post("/test", "", [], creds: %{client_id: "client_id", client_secret: "client_secret"})

      expect HTTPoison |> to(accepted :post, [
        "https://api.github.com/test",
        "",
        default_headers(),
        [params: %{client_id: "client_id", client_secret: "client_secret"}]
      ])
    end

    it "adds application credentials to query parameters" do
      GitHub.post(
        "/test",
        "",
        [],
        creds: %{client_id: "client_id", client_secret: "client_secret"},
        params: %{foo: "bar"}
      )

      expect HTTPoison |> to(accepted :post, [
        "https://api.github.com/test",
        "",
        default_headers(),
        [params: %{
          client_id: "client_id",
          client_secret: "client_secret",
          foo: "bar"
        }]
      ])
    end

    it "adds a basic authentication header when supplied login credentials" do
      GitHub.post("/test", "", [], creds: %{login: "login", password: "password"})

      expect HTTPoison |> to(accepted :post, [
        "https://api.github.com/test",
        "",
        [
          {"User-Agent", user_agent()},
          {"Authorization", "Basic bG9naW46cGFzc3dvcmQ="}
        ],
        []
      ])
    end

    it "doesn't overwrite a user-supplied User-Agent header" do
      GitHub.post("/test", "", [{"User-Agent", "Testy testy test!"}], [])

      expect HTTPoison |> to(accepted :post, [
        "https://api.github.com/test",
        "",
        [{"User-Agent", "Testy testy test!"}],
        []
      ])
    end

    it "uses the user agent from the application configuration" do
      Application.put_env(:octokit, :user_agent, "Testing!")
      GitHub.post("/test", "")

      expect HTTPoison |> to(accepted :post, [
        "https://api.github.com/test",
        "",
        [{"User-Agent", "Testing!"}],
        []
      ])
    end
  end

  describe "put" do
    before do: allow HTTPoison |> to(accept :put, fn(_, _, _, _) -> nil end)

    it "prepends the GitHub API location" do
      GitHub.put("/test", "")

      expect HTTPoison |> to(accepted :put, ["https://api.github.com/test", "", default_headers(), []])
    end

    it "doesn't prepend the API location if it is already there" do
      GitHub.put("https://api.github.com/test", "")

      expect HTTPoison |> to(accepted :put, ["https://api.github.com/test", "", default_headers(), []])
    end

    it "uses token credentials as query parameters" do
      GitHub.put("/test", "", [], creds: %{token: "access_token"})

      expect HTTPoison |> to(accepted :put, [
        "https://api.github.com/test",
        "",
        default_headers(),
        [params: %{token: "access_token"}]
      ])
    end

    it "adds token credentials as query parameters" do
      GitHub.put("/test", "", [], creds: %{token: "access_token"}, params: %{foo: "bar"})

      expect HTTPoison |> to(accepted :put, [
        "https://api.github.com/test",
        "",
        default_headers(),
        [params: %{foo: "bar", token: "access_token"}]
      ])
    end

    it "uses application credentials as query parameters" do
      GitHub.put("/test", "", [], creds: %{client_id: "client_id", client_secret: "client_secret"})

      expect HTTPoison |> to(accepted :put, [
        "https://api.github.com/test",
        "",
        default_headers(),
        [params: %{client_id: "client_id", client_secret: "client_secret"}]
      ])
    end

    it "adds application credentials to query parameters" do
      GitHub.put(
        "/test",
        "",
        [],
        creds: %{client_id: "client_id", client_secret: "client_secret"},
        params: %{foo: "bar"}
      )

      expect HTTPoison |> to(accepted :put, [
        "https://api.github.com/test",
        "",
        default_headers(),
        [params: %{
          client_id: "client_id",
          client_secret: "client_secret",
          foo: "bar"
        }]
      ])
    end

    it "adds a basic authentication header when supplied login credentials" do
      GitHub.put("/test", "", [], creds: %{login: "login", password: "password"})

      expect HTTPoison |> to(accepted :put, [
        "https://api.github.com/test",
        "",
        [
          {"User-Agent", user_agent()},
          {"Authorization", "Basic bG9naW46cGFzc3dvcmQ="}
        ],
        []
      ])
    end

    it "doesn't overwrite a user-supplied User-Agent header" do
      GitHub.put("/test", "", [{"User-Agent", "Testy testy test!"}], [])

      expect HTTPoison |> to(accepted :put, [
        "https://api.github.com/test",
        "",
        [{"User-Agent", "Testy testy test!"}],
        []
      ])
    end

    it "uses the user agent from the application configuration" do
      Application.put_env(:octokit, :user_agent, "Testing!")
      GitHub.put("/test", "")

      expect HTTPoison |> to(accepted :put, [
        "https://api.github.com/test",
        "",
        [{"User-Agent", "Testing!"}],
        []
      ])
    end
  end
end
