defmodule Blog.Api.V3.PostsTest do
  use BlogTest.Case
  use Plug.Test

  alias Blog.Models.Post

  test "GET /v3/posts" do
    {:ok, post1} = Post.create(%{title: "foo", body: "baz"})
    {:ok, post2} = Post.create(%{title: "fu",  body: "bar"})

    expected = %{
      "posts" => [
        %{
          "body"        => "baz",
          "id"          => post1.id,
          "isPublished" => false,
          "title"       => "foo",
          "links"       =>  %{
            "comments"  => %{
              "href" => "http://example.com/v3/posts/#{post1.id}/comments"
            }
          }
        },
        %{
          "body"        => "bar",
          "id"          => post2.id,
          "isPublished" => false,
          "title"       => "fu",
          "links"       => %{
            "comments"  => %{
              "href" => "http://example.com/v3/posts/#{post2.id}/comments"
            }
          }
        }
      ]
    }

    conn = conn("GET", "/v3/posts", nil, [])

    response = Blog.Api.call(conn, [])

    assert 200 = response.status
    assert ["application/vnd.api+json"] = get_resp_header(response, "content-type")
    assert expected == Poison.decode!(response.resp_body)
  end
end
