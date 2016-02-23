defmodule Octokit.Repository do
  @moduledoc """
  Represents a [GitHub repository](https://developer.github.com/v3/repos/#get).
  """

  alias Octokit.Client
  alias Octokit.User

  @type repo :: String.t | t
  @type t :: %__MODULE__{}
  @type user :: String.t | User.t

  @fields [
            :id, :owner, :name, :full_name, :description, :private, :fork,
            :homepage, :language, :forks_count, :stargazers_count,
            :watchers_count, :size, :default_branch, :open_issues_count,
            :has_issues, :has_wiki, :has_pages, :has_downloads, :pushed_at,
            :created_at, :updated_at, :permissions, :subscribers_count,
            :organization, :parent, :source
          ]

  defstruct @fields

  @name_with_owner_pattern ~r{\A[\w.-]+/[\w.-]+\z}i

  @doc """
  Creates a new `Octokit.Repository` structure with the bare minimum information.

  Call `update/2` to fill the rest of the structure from the GitHub database.
  """
  @spec new(user | nil, repo) :: t
  def new(user \\ nil, repo)

  def new(nil, full_name) when is_binary(full_name) do
    if Regex.match?(@name_with_owner_pattern, full_name) do
      [user, repo] = String.split(full_name, "/")

      %__MODULE__{owner: user, name: repo, full_name: full_name}
    end
  end

  def new(user, repo) do
    %__MODULE__{owner: user, name: repo, full_name: "#{user}/#{repo}"}
  end

  @doc """
  Parses the body of an API response into an `Octokit.Repository`.
  """
  @spec parse(String.t) :: t
  def parse(body), do: Octokit.Parser.parse(body, @fields, %__MODULE__{})

  def repo_name?(text), do: Regex.match?(@name_with_owner_pattern, text)

  @doc """
  Updates with the latest information from the GitHub database.
  """
  @spec update(Client.t, repo) :: t
  def update(client, repo) do
    Client.repository(client, repo.full_name)
  end
end
