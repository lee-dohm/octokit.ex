defmodule Octokit.GitHub.Test do
  use ExUnit.Case, async: false
  doctest Octokit.GitHub

  alias Octokit.GitHub
  import Mock
  import Test.Helpers

  setup do
    {:ok, default_header: [{"User-Agent", "lee-dohm/octokit.ex"}]}
  end

  test "prepends the GitHub API location", %{default_header: default_header} do
    with_http_mock do
      GitHub.get("/test")

      assert called HTTPoison.get("https://api.github.com/test", default_header, [])
    end
  end

  test "uses token credentials as query parameters", %{default_header: default_header} do
    with_http_mock do
      GitHub.get("/test", [], creds: %{token: "access_token"})

      assert called HTTPoison.get("https://api.github.com/test",
                                  default_header,
                                  params: %{token: "access_token"})
    end
  end

  test "adds token credentials to query parameters", %{default_header: default_header} do
    with_http_mock do
      GitHub.get("/test", [], creds: %{token: "access_token"}, params: %{foo: "bar"})

      assert called HTTPoison.get("https://api.github.com/test",
                                  default_header,
                                  params: %{foo: "bar", token: "access_token"})
    end
  end

  test "uses application credentials as query parameters", %{default_header: default_header} do
    with_http_mock do
      GitHub.get("/test", [], creds: %{client_id: "client_id", client_secret: "client_secret"})

      assert called HTTPoison.get("https://api.github.com/test",
                                  default_header,
                                  params: %{client_id: "client_id", client_secret: "client_secret"})
    end
  end

  test "adds application credentials to query parameters", %{default_header: default_header} do
    with_http_mock do
      GitHub.get("/test",
                 [],
                 creds: %{client_id: "client_id", client_secret: "client_secret"},
                 params: %{foo: "bar"})

      assert called HTTPoison.get("https://api.github.com/test",
                                  default_header,
                                  params: %{
                                    client_id: "client_id",
                                    client_secret: "client_secret",
                                    foo: "bar"
                                  })
    end
  end

  test "adds basic authentication header when supplied login credentials" do
    with_http_mock do
      GitHub.get("/test", [], creds: %{login: "login", password: "password"})

      assert called HTTPoison.get("https://api.github.com/test",
                                  [
                                    {"User-Agent", "lee-dohm/octokit.ex"},
                                    {"Authorization", "Basic bG9naW46cGFzc3dvcmQ="}
                                  ],
                                  [])
    end
  end

  test "doesn't overwrite a user-supplied User-Agent header" do
    with_http_mock do
      GitHub.get("/test", [{"User-Agent", "testy test test"}], [])

      assert called HTTPoison.get("https://api.github.com/test",
                                  [{"User-Agent", "testy test test"}],
                                  [])
    end
  end
end
