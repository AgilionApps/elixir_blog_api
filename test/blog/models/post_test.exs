defmodule Blog.Models.PostTest do
  use   BlogTest.Case
  alias Blog.Models.Post

  setup do
    attrs = %{
      title: "Elixir APIs, yay!",
      body:  "OMG, Elixir is awesome. Better build a blog!",
    }
    {:ok, attrs: attrs}
  end

  test "creating a post", context do
    assert {:ok, _post} = Post.create(context[:attrs])
  end

  test "creating an invalid post" do
    assert {:error, errors} = Post.create(%{})
    assert errors[:title] == "can't be blank"
    assert errors[:body]  == "can't be blank"
  end

  test "finding a post", context do
    assert {:ok, post} = Post.create(context[:attrs])
    found = Post.find(post.id)
    assert post.id == found.id
    assert post.title == found.title
  end
end
