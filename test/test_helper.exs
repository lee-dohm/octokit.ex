defmodule Test.Helpers do
  @moduledoc """
  Test case helper functions.
  """

  import Mock

  @doc """
  Gets the path to the test fixtures directory.
  """
  def fixture_path, do: Path.expand("fixtures", __DIR__)

  @doc """
  Gets the path to the named test fixture.
  """
  def fixture_path(name), do: Path.join(fixture_path(), name <> ".exs")

  @doc """
  Gets the named test fixture.
  """
  def fixture(name) do
    {result, _} = Code.eval_file(fixture_path(name))
    result
  end

  defmacro with_github_mock(method, fixture_name, block) do
    quote do
      with_mock Octokit.GitHub, [{unquote(method), fn(_, _, _) -> {:ok, fixture(unquote(fixture_name))} end}] do
        unquote(block)
      end
    end
  end

  defmacro with_github_mock(mock_list, block) do
    quote do
      with_mock Octokit.GitHub, unquote(mock_list) do
        unquote(block)
      end
    end
  end
end

ExUnit.start()
