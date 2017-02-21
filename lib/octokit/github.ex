defmodule Octokit.GitHub do
  @doc """
  Executes an HTTP GET operation against the GitHub API endpoint.
  """
  def get(path, headers \\ [], options \\ []) do
    {headers, options} = maybe_handle_credentials(headers, options)
    headers = insert_default_user_agent(headers)

    HTTPoison.get("https://api.github.com" <> path, headers, options)
  end

  defp maybe_handle_credentials(headers, options) do
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

  defp auth_header(login, password) do
    {"Authorization", "Basic " <> Base.encode64(login <> ":" <> password)}
  end

  defp insert_default_user_agent(headers) do
    cond do
      Enum.any?(headers, fn({name, _}) -> name == "User-Agent" end) ->
        headers
      true ->
        [{"User-Agent", "lee-dohm/octokit.ex"} | headers]
    end
  end
end
