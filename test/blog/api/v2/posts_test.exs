defmodule Blog.Api.V2.PostsTest do
  use BlogTest.Case
  use Plug.Test

  alias Blog.Models.Post
  alias Blog.Models.Comment

  @tag :sideload
  test "GET /v2/posts" do
    {:ok, post1} = Post.create(%{title: "foo", body: "baz"})
    {:ok, post2} = Post.create(%{title: "fu",  body: "bar"})
    {:ok, cmnt1} = Comment.create(%{body: "cmnt1", post_id: post1.id})
    {:ok, cmnt2} = Comment.create(%{body: "cmnt2", post_id: post1.id})
    {:ok, cmnt3} = Comment.create(%{body: "cmnt3", post_id: post2.id})
    {:ok, cmnt4} = Comment.create(%{body: "cmnt4", post_id: post2.id})

    expected = %{
      "posts" => [
        %{
          "body"        => "baz",
          "id"          => post1.id,
          "isPublished" => false,
          "title"       => "foo",
          "links"       =>  %{
            "comments" => [cmnt1.id, cmnt2.id]
          }
        },
        %{
          "body"        => "bar",
          "id"          => post2.id,
          "isPublished" => false,
          "title"       => "fu",
          "links"       =>  %{
            "comments" => [cmnt3.id, cmnt4.id]
          }
        },
      ],
      "linked" => %{
        "comments" => [
          %{"id" => cmnt4.id, "body" => "cmnt4", "links" => %{"post" => post2.id}},
          %{"id" => cmnt3.id, "body" => "cmnt3", "links" => %{"post" => post2.id}},
          %{"id" => cmnt2.id, "body" => "cmnt2", "links" => %{"post" => post1.id}},
          %{"id" => cmnt1.id, "body" => "cmnt1", "links" => %{"post" => post1.id}}
        ]
      }
    }

    conn = conn("GET", "/v2/posts", nil, [])

    response = Blog.Api.call(conn, [])

    assert 200 = response.status
    assert ["application/vnd.api+json"] = get_resp_header(response, "content-type")
    assert expected == Poison.decode!(response.resp_body)
  end

  @tag :sideload
  test "GET /v2/posts/:id" do
    {:ok, post1} = Post.create(%{title: "foo", body: "baz"})
    {:ok, cmnt1} = Comment.create(%{body: "cmnt1", post_id: post1.id})
    {:ok, cmnt2} = Comment.create(%{body: "cmnt2", post_id: post1.id})

    conn = conn("GET", "/v2/posts/#{post1.id}", nil, [])

    response = Blog.Api.call(conn, [])

    expected = %{
      "posts" => %{
        "body"        => "baz",
        "id"          => post1.id,
        "title"       => "foo",
        "isPublished" => false,
        "links"       =>  %{
          "comments" => [cmnt1.id, cmnt2.id]
        }
      },
      "linked" => %{
        "comments" => [
          %{"id" => cmnt2.id, "body" => "cmnt2", "links" => %{"post" => post1.id}},
          %{"id" => cmnt1.id, "body" => "cmnt1", "links" => %{"post" => post1.id}}
        ]
      }
    }

    assert 200 = response.status
    assert ["application/vnd.api+json"] = get_resp_header(response, "content-type")
    assert expected == Poison.decode!(response.resp_body)
  end
end
