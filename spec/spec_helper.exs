defmodule Spec.Helpers do
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
  def fixture_path(name), do: Path.join(fixture_path(), name <> ".exs")

  @doc """
  Gets the named test fixture.
  """
  def fixture(name) do
    {result, _} = Code.eval_file(fixture_path(name))
    result
  end
end

ESpec.configure fn(config) ->
  config.before fn(tags) ->
    {:shared, hello: :world, tags: tags}
  end

  config.finally fn(_shared) ->
    :ok
  end
end
