defmodule Blog.Serializers.V3.Post do
  use Relax.Serializer

  path "/v3/posts/:id"

  serialize "posts" do
    attributes [:id, :title, :body, :is_published]
    has_many :comments, link: "/v3/posts/:id/comments"
  end

  def is_published(post, _conn) do
    post.posted_at != nil
  end
end
