defmodule Octokit.Issue do
  @moduledoc """
  Represents an [Issue](https://developer.github.com/v3/issues/#get-a-single-issue).
  """

  @type t :: %__MODULE__{}

  @fields [
            :number, :state, :title, :body, :user, :labels, :assignee,
            :milestone, :locked, :comments, :closed_at, :created_at,
            :updated_at, :closed_by, :url, :pull_request
          ]

  defstruct @fields

  @doc """
  Parses the body of an API response into an `Octokit.Issue`.
  """
  @spec parse(String.t | Map.t) :: t
  def parse(body), do: Octokit.Parser.parse(body, @fields, %__MODULE__{})
end
