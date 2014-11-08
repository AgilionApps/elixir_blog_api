defmodule Blog.Serializers.V1.Post do
  use Blog.Serializer

  serialize "posts" do
    attributes [:id, :title, :body, :is_published]
    has_many :comments, ids: true, fn: :comment_ids
  end

  def is_published(post) do
    post.posted_at != nil
  end

  def comment_ids(post) do
    Enum.map post.comments.all, &(&1.id)
  end
end
