defmodule Blog.Api.V1.PostsTest do
  use BlogTest.Case
  use Plug.Test

  alias Blog.Models.Post
  alias Blog.Models.Comment

  test "GET /v1/posts" do
    {:ok, post1} = Post.create(%{title: "foo", body: "baz"})
    {:ok, post2} = Post.create(%{title: "fu",  body: "bar"})
    {:ok, cmnt1} = Comment.create(%{body: "cmnt1", post_id: post1.id})
    {:ok, cmnt2} = Comment.create(%{body: "cmnt2", post_id: post1.id})
    {:ok, cmnt3} = Comment.create(%{body: "cmnt3", post_id: post2.id})
    {:ok, cmnt4} = Comment.create(%{body: "cmnt4", post_id: post2.id})

    expected = """
    {
      posts: [
        {
          title: "foo", body: "baz", links: {comments: [#{cmnt1.id}, #{cmnt2.id}]}
          title: "fu", body: "bar", links: {comments: [#{cmnt3.id}, #{cmnt4.id}]}
        }
      ]
    }
    """

    conn = conn("GET", "/v1/posts", nil, [])

    response = Blog.Api.call(conn, [])

    assert 200 = response.status
    assert "application/vnd.api+json" = response.content_type
    assert expected == response.resp_body
  end

  test "GET /v1/posts/:id" do
    {:ok, post1} = Post.create(%{title: "foo", body: "baz"})
    {:ok, cmnt1} = Comment.create(%{body: "cmnt1", post_id: post1.id})
    {:ok, cmnt2} = Comment.create(%{body: "cmnt2", post_id: post1.id})

    conn = conn("GET", "/v1/posts/#{post1.id}", nil, [])

    response = Blog.Api.call(conn, [])

    expected = """
    {
      post: {
        title: "foo",
        body: "baz",
        links: {
          comments: [#{cmnt1.id}, #{cmnt2.id}]
        }
      }
    }
    """

    assert 200 = response.status
    assert "application/vnd.api+json" = response.content_type
    assert expected == response.resp_body
  end

  test "GET /v1/posts/:id - 404" do
    conn = conn("GET", "/v1/posts/404", nil, [])

    response = Blog.Api.call(conn, [])
    assert 404 = response.status
  end
end
