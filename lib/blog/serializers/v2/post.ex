defmodule Blog.Serializers.V2.Post do
  use Relax.Serializer

  path "/v2/posts/:id"

  serialize "posts" do
    attributes [:id, :title, :body, :is_published]
    has_many :comments, serializer: Blog.Serializers.V2.Comment
  end

  def is_published(post, _conn), do: post.posted_at != nil

  def comments(post, _conn), do: post.comments.all
end
