defmodule Test.Helpers do
  def fixture_path do
    Path.expand("fixtures", __DIR__)
  end

  def fixture_path(filename) do
    Path.join(fixture_path, filename <> ".exs")
  end

  def fixture(filename) do
    {result, _} = Code.eval_file(fixture_path(filename))
    result
  end

  def mock_get(fixture_name) do
    [get: fn(_) -> {:ok, fixture(fixture_name)} end]
  end
end

ExUnit.start()
