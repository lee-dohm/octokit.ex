defmodule Octokit.GitHub do
  @moduledoc """
  Wrapper around `HTTPoison` to handle low-level GitHub API interactions.
  """

  @type headers :: [{String.t, String.t}] | %{String.t => String.t}
  @type options :: Keyword.t | Map.t

  @doc """
  Executes an HTTP GET operation against the GitHub API endpoint.

  The arguments are the same as for `HTTPoison.get/3` except:

  * `path` Accepts either a full URL or the API path
  * `options` supports additional keys:
      * `:creds` Client credentials to use to authenticate against the GitHub API
  """
  @spec get(String.t, headers, options) :: {:ok, HTTPoison.Response.t} | {:error, HTTPoison.Error.t}
  def get(path, headers \\ [], options \\ []) do
    {headers, options} = handle_credentials(headers, options)

    headers = maybe_insert_user_agent(headers)
    url = maybe_prepend_api_host(path)

    HTTPoison.get(url, headers, options)
  end

  def post(path, body, headers \\ [], options \\ []) do
    {headers, options} = handle_credentials(headers, options)

    headers = maybe_insert_user_agent(headers)
    url = maybe_prepend_api_host(path)

    HTTPoison.post(url, body, headers, options)
  end

  def put(path, body \\ "", headers \\ [], options \\ []) do
    {headers, options} = handle_credentials(headers, options)

    headers = maybe_insert_user_agent(headers)
    url = maybe_prepend_api_host(path)

    HTTPoison.put(url, body, headers, options)
  end

  defp auth_header(login, password) do
    {"Authorization", "Basic " <> Base.encode64(login <> ":" <> password)}
  end

  defp handle_credentials(headers, options) do
    handle_credentials(headers, Keyword.delete(options, :creds), Keyword.fetch(options, :creds))
  end

  defp handle_credentials(headers, options, :error) do
    {headers, options}
  end

  defp handle_credentials(headers, options, {:ok, creds = %{token: _}}) do
    {headers, Keyword.update(options, :params, creds, &(Map.merge(&1, creds)))}
  end

  defp handle_credentials(headers, options, {:ok, creds = %{client_id: _, client_secret: _}}) do
    {headers, Keyword.update(options, :params, creds, &(Map.merge(&1, creds)))}
  end

  defp handle_credentials(headers, options, {:ok, %{login: login, password: password}}) do
    {[auth_header(login, password) | headers], options}
  end

  defp maybe_insert_user_agent(headers) do
    case Enum.any?(headers, fn({name, _}) -> name == "User-Agent" end) do
      true -> headers
      _ -> [{"User-Agent", Application.get_env(:octokit, :user_agent)} | headers]
    end
  end

  defp maybe_prepend_api_host(url = <<"https://api.github.com", _ :: binary>>), do: url
  defp maybe_prepend_api_host(path), do: "https://api.github.com" <> path
end
