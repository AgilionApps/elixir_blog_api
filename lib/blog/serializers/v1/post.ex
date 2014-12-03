defmodule Blog.Serializers.V1.Post do
  use Relax.Serializer

  path "/v1/posts/:id"

  serialize "posts" do
    attributes [:id, :title, :body, :is_published]
    has_many :comments, ids: true
  end

  def is_published(post, _conn) do
    post.posted_at != nil
  end

  def comments(post, _conn) do
    Enum.map post.comments.all, &(&1.id)
  end
end
