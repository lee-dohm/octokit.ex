# Octokit

[![Build Status](https://img.shields.io/travis/lee-dohm/octokit.ex.svg)](https://travis-ci.org/lee-dohm/octokit.ex)
[![Package Version](https://img.shields.io/hexpm/v/octokit.svg)](https://atom.io/packages/octokit)

An Elixir library for accessing the [GitHub API](https://developer.github.com/v3/).

Like all versions of Octokit, this project does its best to conform to the community standards for the language it is written in and for. If there are places where this library does not conform, please [file an Issue](https://github.com/lee-dohm/octokit.ex/issues/new).

## Installation

First, add Octokit to your `mix.exs` dependencies:

```elixir
def deps do
  [ {:octokit, "~> 0.1.0"} ]
end
```

and run `mix deps.get`. Now, list the `:octokit` application as an application dependency:

```elixir
def application do
  [applications: [:octokit]]
end
```

The user agent used by Octokit to connect to the GitHub API can be configured by adding the following to your `config.exs`:

```elixir
config :octokit, :user_agent, "YourUserAgent"
```

## Development

This project follows the [GitHub "scripts to rule them all" pattern](http://githubengineering.com/scripts-to-rule-them-all/). The contents of the `scripts` directory are scripts that cover all common tasks:

* `script/setup` &mdash; Performs first-time setup
* `script/update` &mdash; Performs periodic updating
* `script/test` &mdash; Runs automated tests
* `script/console` &mdash; Opens the development console

Other scripts that are available but not intended to be used directly by developers:

* `script/bootstrap` &mdash; Used to do a one-time install of all prerequisites for a development machine
* `script/cibuild` &mdash; Used to run automated tests in the CI environment

## Testing

### Mock API Responses

All mock API responses are stored in IEx `inspect` output for easy deserialization into native Elixir data structures. The format of the files in `test/fixtures` is:

* Commented out `HTTPoison.get!` API call used to retrieve the response
* Response object returned from the above API call

### Test Helpers for Fixtures and Mocks

In any `ExUnit.Case` using module, import `Test.Helpers`. See `test/test_helper.exs` for the current list of helpers and documentation.

## Copyright

Copyright &copy; 2016 by [Lee Dohm](http://www.lee-dohm.com). See [LICENSE](https://raw.githubusercontent.com/lee-dohm/octokit.ex/master/LICENSE.md) for details.
