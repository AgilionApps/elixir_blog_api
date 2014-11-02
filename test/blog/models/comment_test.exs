defmodule Blog.Models.CommentTest do
  use BlogTest.Case
  alias Blog.Models.Comment

  setup do
    post_attrs = %{title: "foo", body: "bar"}
    {:ok, post} = Blog.Models.Post.create(post_attrs)
    attrs = %{
      body:    "VERY API. SUCH FUNCTION. MUCH PROCESS. SO API",
      post_id: post.id
    }
    {:ok, attrs: attrs, post: post}
  end

  test "creating a comment", context do
    assert {:ok, _comment} = Comment.create(context[:attrs])
  end

  test "creating an invalid comment" do
    assert {:error, errors} = Comment.create(%{})
    assert errors[:body]  == "can't be blank"
  end

  test "finding a comment", context do
    assert {:ok, comment} = Comment.create(context[:attrs])
    assert ^comment = Comment.find(comment.id)
  end
end
