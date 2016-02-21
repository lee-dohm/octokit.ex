defmodule Octokit.Storage do
  @moduledoc """
  Stores state information for Client sessions.
  """

  @doc """
  Creates a new state store.
  """
  def new do
    {:ok, store} = Agent.start_link(fn -> %{} end)
    store
  end

  @doc """
  Gets the entire contents of the store.
  """
  def get(store) do
    Agent.get(store, fn contents -> contents end)
  end

  @doc """
  Gets the value for `key` in the store.
  """
  def get(store, key) do
    Agent.get(store, &Map.fetch!(&1, key))
  end

  @doc """
  Puts the contents of `map` into the store.

  If `map` has a value for a key that is already in the store, the new value in
  `map` will overwrite the one in the store.
  """
  def put(store, map) do
    Agent.update(store, &Map.merge(&1, map))
  end

  @doc """
  Stores `value` for `key`.

  If `key` already exists in the store, its value will be overwritten with
  `value`.
  """
  def put(store, key, value) do
    Agent.update(store, &Map.put(&1, key, value))
  end
end
