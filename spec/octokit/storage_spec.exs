defmodule Octokit.Storage.Spec do
  use ESpec, async: true
  doctest Octokit.Storage

  alias Octokit.Storage

  let :storage, do: Storage.new

  it "starts empty" do
    expect storage() |> Storage.get |> to(eq %{})
  end

  it "stores key/value pairs" do
    Storage.put(storage(), "foo", "bar")

    expect storage() |> Storage.get |> to(eq %{"foo" => "bar"})
  end

  it "stores entire maps" do
    map = %{client_id: "client_id", client_secret: "client_secret"}
    Storage.put(storage(), map)

    expect storage() |> Storage.get |> to(eq map)
  end

  it "overwrites values when the same key is used" do
    Storage.put(storage(), "foo", "bar")
    Storage.put(storage(), "foo", "baz")

    expect storage() |> Storage.get |> to(eq %{"foo" => "baz"})

    Storage.put(storage(), "foo", "quux")

    expect storage() |> Storage.get |> to(eq %{"foo" => "quux"})
  end

  it "gets a single value" do
    map = %{client_id: "client_id", client_secret: "client_secret"}
    Storage.put(storage(), map)

    expect storage() |> Storage.get(:client_id) |> to(eq "client_id")
  end
end
