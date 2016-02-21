defmodule Octokit.Storage.Test do
  use ExUnit.Case
  doctest Octokit.Storage

  alias Octokit.Storage

  setup do
    {:ok, storage: Storage.new,
          client: %{client_id: "client_id", client_secret: "client_secret"}
    }
  end

  test "starts empty", %{storage: storage} do
    assert Storage.get(storage) == %{}
  end

  test "stores key/value pairs", %{storage: storage} do
    Storage.put(storage, "foo", "bar")

    assert Storage.get(storage) == %{"foo" => "bar"}
  end

  test "stores entire maps", %{storage: storage, client: client_map} do
    Storage.put(storage, client_map)

    assert Storage.get(storage) == client_map
  end

  test "new values overwrite old ones", %{storage: storage} do
    Storage.put(storage, "foo", "bar")
    Storage.put(storage, "foo", "baz")

    assert Storage.get(storage) == %{"foo" => "baz"}

    Storage.put(storage, %{"foo" => "quux"})

    assert Storage.get(storage) == %{"foo" => "quux"}
  end

  test "get a single value", %{storage: storage, client: client_map} do
    Storage.put(storage, client_map)

    assert Storage.get(storage, :client_id) == "client_id"
  end
end
