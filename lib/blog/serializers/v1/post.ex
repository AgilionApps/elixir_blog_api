defmodule Blog.Serializers.V1.Post do
  use JsonApi.Serializer

  serialize "posts" do
    attributes [:id, :title, :body, :is_published]
    has_many :comments, ids: true
  end

  def is_published(post) do
    post.posted_at != nil
  end

  def comments(post) do
    Enum.map post.comments.all, &(&1.id)
  end
end
