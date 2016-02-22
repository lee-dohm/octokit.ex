defmodule Test.Helpers do
  @moduledoc """
  Test case helper functions.
  """

  @doc """
  Gets the path to the test fixtures directory.
  """
  def fixture_path, do: Path.expand("fixtures", __DIR__)

  @doc """
  Gets the path to the named test fixture.
  """
  def fixture_path(name), do: Path.join(fixture_path, name <> ".exs")

  @doc """
  Gets the named test fixture.
  """
  def fixture(name) do
    {result, _} = Code.eval_file(fixture_path(name))
    result
  end

  @doc """
  Creates a [Mock](https://hex.pm/packages/mock)-compatible mock declaration for
  an `HTTPoison.get` API call based on the named test fixture.
  """
  def mock_get(fixture_name) do
    [get: fn(_) -> {:ok, fixture(fixture_name)} end]
  end
end

ExUnit.start()
