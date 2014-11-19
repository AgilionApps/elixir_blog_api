defmodule Blog.Api.V1.CommentsTest do
  use BlogTest.Case
  use Plug.Test

  alias Blog.Models.Post
  alias Blog.Models.Comment

  test "GET /v1/comments" do
    {:ok, post1} = Post.create(%{title: "foo", body: "baz"})
    {:ok, post2} = Post.create(%{title: "fu",  body: "bar"})
    {:ok, cmnt1} = Comment.create(%{body: "cmnt1", post_id: post1.id})
    {:ok, cmnt2} = Comment.create(%{body: "cmnt2", post_id: post2.id})

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
          "links" => %{ "post" => post2.id }
        }
      ]
    }

    conn = conn("GET", "/v1/comments", nil, [])

    response = Blog.Api.call(conn, [])

    assert 200 = response.status
    assert ["application/vnd.api+json"] = get_resp_header(response, "content-type")
    assert expected == Poison.decode!(response.resp_body)
  end

  test "GET /v1/comments?ids=[:id1,:id2]" do
    {:ok, post1} = Post.create(%{title: "foo", body: "baz"})
    {:ok, post2} = Post.create(%{title: "fu",  body: "bar"})
    {:ok, cmnt1} = Comment.create(%{body: "cmnt1", post_id: post1.id})
    {:ok, cmnt2} = Comment.create(%{body: "cmnt2", post_id: post2.id})
    {:ok, cmnt3} = Comment.create(%{body: "cmnt3", post_id: post1.id})
    {:ok, cmnt4} = Comment.create(%{body: "cmnt4", post_id: post2.id})

    expected = %{
      "comments" => [
        %{
          "id"    => cmnt1.id,
          "body"  => "cmnt1",
          "links" => %{ "post" => post1.id }
        },
        %{
          "id"    => cmnt3.id,
          "body"  => "cmnt3",
          "links" => %{ "post" => post1.id }
        }
      ]
    }

    conn = conn("GET", "/v1/comments/#{cmnt1.id},#{cmnt3.id}", nil, [])

    response = Blog.Api.call(conn, [])

    assert 200 = response.status
    assert ["application/vnd.api+json"] = get_resp_header(response, "content-type")
    assert expected == Poison.decode!(response.resp_body)
  end

  test "GET /v1/comments/:id" do
    {:ok, post1} = Post.create(%{title: "foo", body: "baz"})
    {:ok, cmnt1} = Comment.create(%{body: "cmnt1", post_id: post1.id})

    expected = %{
      "comments" => %{
        "id"    => cmnt1.id,
        "body"  => "cmnt1",
        "links" => %{ "post" => post1.id }
      }
    }

    conn = conn("GET", "/v1/comments/#{cmnt1.id}", nil, [])

    response = Blog.Api.call(conn, [])

    assert 200 = response.status
    assert ["application/vnd.api+json"] = get_resp_header(response, "content-type")
    assert expected == Poison.decode!(response.resp_body)
  end

  test "POST /v1/comments" do
    {:ok, post1} = Post.create(%{title: "foo", body: "baz"})

    request = %{
      "comments" => %{
        "body"  => "cmnt1",
        "links" => %{ "post" => post1.id }
      }
    }

    headers = [{"content-type", "application/vnd.api+json"}]
    body = Poison.encode!(request)

    conn = conn("POST", "/v1/comments/", body, headers: headers)
    response = Blog.Api.call(conn, [])
    assert 201 = response.status

    json = Poison.decode!(response.resp_body)
    id = json["comments"]["id"]
    assert is_number(id)
    assert "cmnt1" = json["comments"]["body"]
    assert post1.id == json["comments"]["links"]["post"]

    assert ["application/vnd.api+json"] = get_resp_header(response, "content-type")
    assert ["http://example.com/v1/comments/#{id}"] == get_resp_header(response, "Location")
  end
end
