defmodule Octokit.Repository.Spec do
  use ESpec, async: true
  doctest Octokit.Repository

  alias Octokit.Repository

  describe "creating a new repository" do
    it "from an owner and repo name works" do
      repo = Repository.new("foo", "bar")

      expect repo.owner |> to(eq "foo")
      expect repo.name |> to(eq "bar")
      expect repo.full_name |> to(eq "foo/bar")
    end

    it "from a full name works" do
      repo = Repository.new("foo/bar")

      expect repo.owner |> to(eq "foo")
      expect repo.name |> to(eq "bar")
      expect repo.full_name |> to(eq "foo/bar")
    end
  end

  describe "repo_name?" do
    it "accepts foo/bar" do
      expect "foo/bar" |> Repository.repo_name? |> to(be_true())
    end

    it "rejects foo by itself" do
      expect "foo" |> Repository.repo_name? |> to(be_false())
    end
  end
end
