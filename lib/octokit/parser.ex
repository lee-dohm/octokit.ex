defmodule Octokit.Parser do
  @moduledoc """
  Functions to parse GitHub API responses into structs.
  """

  @typedoc """
  List of fields to copy from the parsed data.
  """
  @type field_list :: nonempty_list(atom)

  @doc """
  Parses the information, copying the named fields into a struct.

  It can parse either JSON or a `Map`.

  ## Examples

  Parsing a JSON object

      iex> foo = Octokit.Parser.parse("{\\"test\\": 1}", [:test], %Octokit.Repository{})
      iex> foo.test
      1

  Parsing an equivalent `Map`

      iex> foo = Octokit.Parser.parse(%{"test" => 1}, [:test], %Octokit.Repository{})
      iex> foo.test
      1
  """
  @spec parse(String.t | Map.t, field_list, struct) :: struct
  def parse(data, fields, struct)

  def parse(body, fields, struct) when is_binary(body) do
    Poison.Parser.parse!(body)
    |> parse(fields, struct)
  end

  def parse(data, fields, struct) when is_map(data) do
    Enum.reduce(fields, struct, fn(field, map) ->
      Map.put(map, field, data[Atom.to_string(field)])
    end)
  end
end
