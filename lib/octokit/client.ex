defmodule Octokit.Client do
  @moduledoc """
  A client to retrieve information from the [GitHub API](https://developer.github.com/v3/).

  This client does minimal caching, only retaining the very last response from any call to the API.
  It also doesn't do anything to ensure that you stay under your respective rate limit, though it
  does make the rate limit information available.

  ## Security Warning

  This client does not store the credentials it is supplied in a secure manner. Any process that
  has access to the client `pid` can retrieve the credentials in plaintext.
  """

  alias Octokit.Client
  alias Octokit.Issue
  alias Octokit.Repository
  alias Octokit.Storage
  alias Octokit.User

  require Logger

  @type creds :: %{}
  @type issue_number :: pos_integer | String.t
  @type rate_limit :: %{limit: Integer.t, remaining: Integer.t, reset: Integer.t}
  @type rel_name :: :first | :prev | :next | :last
  @type repo :: pos_integer | String.t | Repository.t
  @type request_opts :: Keyword.t
  @type user :: String.t | User.t
  @type t :: pid

  defmodule InvalidCredentialsError do
    @moduledoc """
    Error raised when invalid client credentials are supplied.
    """

    defexception [:message]

    def exception(params) do
      message = "Invalid client credentials: #{inspect params}"
      %InvalidCredentialsError{message: message}
    end
  end

  defmodule NotFoundError do
    @moduledoc """
    Error raised when the target of an API request is not found.
    """

    defexception [:message]

    def exception(module, body) do
      message = "#{module} not found:\n#{body}"
      %NotFoundError{message: message}
    end
  end

  @doc """
  Creates a new GitHub API client using the supplied credentials.

  ## Examples

  Creating an unauthenticated client:

      iex> client = Octokit.Client.new
      iex> is_pid(client)
      true

  Creating a client with an application's client ID and secret:

      iex> client = Octokit.Client.new(id: "client_id", secret: "client_secret")
      iex> is_pid(client)
      true

  Creating a client with a user's token:

      iex> client = Octokit.Client.new(token: "access_token")
      iex> is_pid(client)
      true
  """
  @spec new(creds) :: t
  def new(credentials \\ [])

  def new([]), do: create_store(%{})
  def new(token: token), do: create_store(%{access_token: token})
  def new(id: id, secret: secret), do: create_store(%{client_id: id, client_secret: secret})
  def new(creds), do: raise InvalidCredentialsError, creds

  @doc """
  Gets the credentials used to create the client.
  """
  @spec credentials(t) :: creds
  def credentials(client) do
    Storage.get(client, :credentials)
  end

  @doc """
  Gets information on a single issue.
  """
  @spec issue(t, repo, issue_number, request_opts) :: {:ok, Issue.t} | {:error, any}
  def issue(client, repo, number, opts \\ []) do
    request(client, "repos/#{repo}/issues/#{number}", opts)
    |> parse_response(Issue)
  end

  @doc """
  Gets the last response object received from an API call.
  """
  @spec last_response(t) :: %HTTPoison.Response{}
  def last_response(client), do: Storage.get(client, :last_response)

  @doc """
  Gets information on all of the issues in a repo or org.
  """
  @spec list_issues(t, repo, request_opts) :: {:ok, [Issue.t]} | {:error, any}
  def list_issues(client, repo, opts \\ []) do
    query_type = issue_query_type(repo)

    request(client, "#{query_type}/#{repo}/issues", opts)
    |> parse_response(Issue)
  end

  @doc """
  Gets the rate limit information from the last response.

  If there is no last response available, it makes a call to the rate limit API.
  """
  @spec rate_limit(t) :: rate_limit
  def rate_limit(client) do
    if is_nil(Client.last_response(client)), do: request(client, "rate_limit", [])

    parse_rate_limit(Client.last_response(client))
  end

  @doc """
  Gets the rate limit informaiton from the API.
  """
  @spec rate_limit!(t) :: rate_limit
  def rate_limit!(client) do
    Storage.put(client, %{last_response: nil})
    rate_limit(client)
  end

  @doc """
  Gets the URL for the named relative link from the last response.

  `rel_name` can be any of the following:

  * `:first` - URL to the first page of information
  * `:prev` - URL to the previous page of information
  * `:next` - URL to the next page of information
  * `:last` - URL to the last page of information

  If `:first` and `:prev` are not defined, then the last response was the first page of information.
  If `:next` and `:last` are not defined, then the last response was the last page of information.
  Obviously, if none of them are defined, the last response contained all information requested.
  """
  @spec rels(t, rel_name) :: String.t
  def rels(client, name) do
    Client.last_response(client)
    |> get_header("Link")
    |> parse_rels
    |> Map.get(Atom.to_string(name))
  end

  @doc """
  Gets information on a single repository.
  """
  @spec repository(t, repo, request_opts) :: {:ok, Repository.t} | {:error, any}
  def repository(client, repo, opts \\ [])

  def repository(client, repo, opts) do
    request(client, "repos/#{repo}", opts)
    |> parse_response(Repository)
  end

  @doc """
  Gets information on a single user.
  """
  @spec user(t, user, request_opts) :: {:ok, User.t} | {:error, any}
  def user(client, user, opts \\ [])

  def user(client, login, opts) when is_binary(login) do
    request(client, "users/#{login}", opts)
    |> parse_response(User)
  end

  defp api_url(path), do: "https://api.github.com/#{path}"
  defp api_url(path, params), do: api_url(path) <> "?#{URI.encode_query(params)}"

  defp create_store(creds) do
    client = Storage.new
    Storage.put(client, %{credentials: creds, last_response: nil})

    client
  end

  defp get_header(response, name, module) do
    value = get_header(response, name)

    module.parse(value)
  end

  defp get_header(response, name) do
    {_, value} = Enum.find(response.headers, fn({key, _}) -> key == name end)

    value
  end

  defp issue_query_type(name) do
    cond do
      Repository.repo_name?(name) -> "repos"
      true                        -> "orgs"
    end
  end

  defp parse_data(data, module) when is_list(data),
    do: Enum.map(data, fn(item) -> module.parse(item) end)

  defp parse_data(data, module), do: module.parse(data)

  defp parse_rate_limit(response) do
    {limit, _} = get_header(response, "X-RateLimit-Limit", Integer)
    {remaining, _} = get_header(response, "X-RateLimit-Remaining", Integer)
    {reset, _} = get_header(response, "X-RateLimit-Reset", Integer)

    %{limit: limit, remaining: remaining, reset: reset}
  end

  defp parse_rel(raw) do
    %{"url" => url, "name" => name} =
      Regex.named_captures(~r/<(?<url>[^>]+)>;\s*rel="(?<name>[^"]+)"/, raw)

    %{name => url}
  end

  defp parse_rels(raw) do
    String.split(raw, ~r/\s*,\s*/)
    |> Enum.reduce(%{}, fn(item, result) -> Map.merge(result, parse_rel(item)) end)
  end

  defp parse_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}, module) do
    {:ok, parse_data(Poison.Parser.parse!(body), module)}
  end

  defp parse_response({:ok, %HTTPoison.Response{status_code: 404, body: body}}, module) do
    {:error, NotFoundError.exception(module, body)}
  end

  defp request(client, path, opts) do
    params = opts
             |> Enum.into(%{})
             |> Map.merge(credentials(client))

    api_url(path, params)
    |> request(client)
  end

  defp request(url) do
    Logger.debug("GET #{url}")
    HTTPoison.get(url)
  end

  defp request(url, client) do
    {_, obj} = response = request(url)

    Storage.put(client, %{last_response: obj})

    response
  end
end
