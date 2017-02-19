defmodule Test.Helpers do
  @moduledoc """
  Test case helper functions.
  """

  import Mock

  def api_url, do: "https://api.github.com"
  def api_url(path), do: Path.join(api_url(), path)
  def api_url(path, params), do: api_url(path) <> "?" <> URI.encode_query(params)

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

  # defmacro with_http_mock(fixture_name, block) do
  #   quote do
  #     with_mock HTTPoison, [get: fn(_) -> {:ok, fixture(unquote(fixture_name))} end] do
  #       unquote(block)
  #     end
  #   end
  # end

  defmacro with_http_mock(method, fixture_name, block) when is_binary(fixture_name) do
    quote do
      with_mock HTTPoison, [{unquote(method), fn(_, _, _) -> {:ok, fixture(unquote(fixture_name))} end}] do
        unquote(block)
      end
    end
  end

  defmacro with_http_mock(mock_list, block) when is_list(mock_list) do
    quote do
      with_mock HTTPoison, unquote(mock_list) do
        unquote(block)
      end
    end
  end
end

ExUnit.start()
