defmodule Octokit.Mixfile do
  use Mix.Project

  @version File.read!("VERSION.md") |> String.strip

  def project do
    [
      app: :octokit,
      name: "Octokit",
      version: @version,
      source_url: "https://github.com/lee-dohm/octokit.ex",
      homepage_url: "https://github.com/lee-dohm/octokit.ex",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      docs: docs(),
      package: package()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications: app_list()
    ]
  end

  defp app_list do
    [
      :logger,
      :httpoison,
      :poison,
      :timex
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:httpoison, "~> 0.11.0"},
      {:poison, "~> 1.5 or ~> 2.0"},
      {:timex, "~> 3.1"},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev},
      {:mock, "~> 0.2.1", only: :test}
    ]
  end

  defp description do
    """
    An Elixir library for accessing the GitHub API.
    """
  end

  defp docs do
    [
      extras: ["CODE_OF_CONDUCT.md", "LICENSE.md": [title: "License"], "README.md": [title: "README"]]
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "*.md"],
      maintainers: ["Lee Dohm"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/lee-dohm/octokit.ex"}
    ]
  end
end
