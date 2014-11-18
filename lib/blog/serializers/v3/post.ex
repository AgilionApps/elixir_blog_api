defmodule Blog.Serializers.V3.Post do
  use JsonApi.Serializer

  path "/v3/posts/:id"

  serialize "posts" do
    attributes [:id, :title, :body, :is_published]
    has_many :comments, link: "/v3/posts/:id/comments"
  end

  def is_published(post) do
    post.posted_at != nil
  end
end
