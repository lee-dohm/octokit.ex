defmodule Octokit.Parser do
  @moduledoc """
  General parsing functions for GitHub API responses.
  """

  @type field_list :: nonempty_list(atom)

  @doc """
  Parses the the respones either in JSON `String` or `Map` form, inserts any
  matches for `fields` and returns in a record of `struct` type.

  ## Examples

      iex> foo = Octokit.Parser.parse("{\\"test\\": 1}", [:test], %Octokit.Repository{})
      iex> foo.test
      1
  """
  @spec parse(String.t | Map.t, field_list, %{}) :: %{}
  def parse(data, fields, struct)

  def parse(body, fields, struct) when is_binary(body) do
    data = Poison.Parser.parse!(body)

    parse(data, fields, struct)
  end

  def parse(data, fields, struct) when is_map(data) do
    Enum.reduce(fields, struct,
      fn(field, map) -> Map.put(map, field, data[Atom.to_string(field)]) end)
  end
end
