defmodule Blog.Api.V3.CommentsTest do
  use BlogTest.Case
  use Plug.Test

  alias Blog.Models.Post
  alias Blog.Models.Comment

  test "GET /v3/posts/:id/comments" do
    {:ok, post1} = Post.create(%{title: "foo", body: "baz"})
    {:ok, post2} = Post.create(%{title: "foo", body: "baz"})
    {:ok, cmnt1} = Comment.create(%{body: "cmnt1", post_id: post1.id})
    {:ok, cmnt2} = Comment.create(%{body: "cmnt2", post_id: post1.id})
    {:ok, cmnt3} = Comment.create(%{body: "cmnt3", post_id: post2.id})

    expected = %{
      "comments" => [
        %{
          "id"    => cmnt1.id,
          "body"  => "cmnt1",
          "links" => %{ "post" => post1.id }
        },
        %{
          "id"    => cmnt2.id,
          "body"  => "cmnt2",
          "links" => %{ "post" => post1.id }
        }
      ]
    }

    conn = conn("GET", "/v3/posts/#{post1.id}/comments", nil, [])

    response = Blog.Api.call(conn, [])

    assert 200 = response.status
    assert ["application/vnd.api+json"] = get_resp_header(response, "content-type")
    assert expected == Poison.decode!(response.resp_body)
  end
end
