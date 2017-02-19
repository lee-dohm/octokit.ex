defmodule Octokit.GitHub do
  use HTTPoison.Base

  def process_url(url), do: "https://api.github.com" <> url
end
