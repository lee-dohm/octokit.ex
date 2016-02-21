defmodule Octokit.Issue do
  @moduledoc """
  Represents a [GitHub issue record](https://developer.github.com/v3/issues/#get-a-single-issue).
  """

  @type t :: %__MODULE__{}

  @fields [
            :number, :state, :title, :body, :user, :labels, :assignee,
            :milestone, :locked, :comments, :closed_at, :created_at,
            :updated_at, :closed_by
          ]

  defstruct @fields

  @doc """
  Parses the JSON body of a GitHub API response to construct an Issue structure.
  """
  @spec parse(String.t) :: t
  def parse(body), do: Octokit.Parser.parse(body, @fields, %__MODULE__{})
end
