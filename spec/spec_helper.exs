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

  defmacro accept_get_and_return_fixture(fixture_name) do
    quote do
      accept :get, fn(_, _, _) -> {:ok, fixture(unquote(fixture_name))} end
    end
  end

  defmacro have_all_struct(type) do
    quote do
      have_all fn
        %{__struct__: unquote(type)} -> true
        _ -> false
      end
    end
  end

  defmacro with_args(path, headers, options) do
    quote do
      [unquote(path), unquote(headers), unquote(options)]
    end
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
