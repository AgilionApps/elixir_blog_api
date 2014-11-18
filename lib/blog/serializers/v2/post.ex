defmodule Blog.Serializers.V2.Post do
  use JsonApi.Serializer

  path "/v2/posts/:id"

  serialize "posts" do
    attributes [:id, :title, :body, :is_published]
    has_many :comments, serializer: Blog.Serializers.V2.Comment
  end

  def is_published(post), do: post.posted_at != nil

  def comments(post), do: post.comments.all
end
