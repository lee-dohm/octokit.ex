# Octokit

An Elixir library for accessing the [GitHub API](https://developer.github.com/v3/).

Like all versions of Octokit, this project does its best to conform to the community standards for the language it is written in and for. If there are places where this library does not conform, please [file an Issue](https://github.com/lee-dohm/octokit.ex/issues/new).

## Common Tasks

This project follows the [GitHub "scripts to rule them all" pattern](http://githubengineering.com/scripts-to-rule-them-all/). The contents of the `scripts` directory are scripts that cover all common tasks:

* `script/setup` &mdash; Performs first-time setup
* `script/update` &mdash; Performs periodic updating
* `script/test` &mdash; Runs automated tests
* `script/console` &mdash; Opens the development console

Other scripts that are available but not intended to be used directly by developers:

* `script/bootstrap` &mdash; Used to do a one-time install of all prerequisites for a development machine
* `script/cibuild` &mdash; Used to run automated tests in the CI environment

## Copyright

Copyright &copy; 2016 by [Lee Dohm](http://www.lee-dohm.com). See [LICENSE](https://raw.githubusercontent.com/lee-dohm/octokit.ex/master/LICENSE.md) for details.
