defmodule Octokit.Repository.Test do
  use ExUnit.Case, async: false
  doctest Octokit.Repository

  alias Octokit.Repository

  test "creating a new Repository from an owner and repo name" do
    repo = Repository.new("foo", "bar")

    assert repo.owner == "foo"
    assert repo.name == "bar"
    assert repo.full_name == "foo/bar"
  end

  test "creating a new Repository from a full name" do
    repo = Repository.new("foo/bar")

    assert repo.owner == "foo"
    assert repo.name == "bar"
    assert repo.full_name == "foo/bar"
  end

  test "detects foo/bar as a repo name" do
    assert Repository.repo_name?("foo/bar")
  end

  test "rejects foo alone as a repo name" do
    refute Repository.repo_name?("foo")
  end
end
