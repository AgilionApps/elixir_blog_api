defmodule Blog.Models.Comment do
  use    Ecto.Model
  import Ecto.Query, only: [from: 2]
  alias  Blog.Repo

  schema "comments" do
    field :body,       :string
    field :created_at, :datetime
    field :updated_at, :datetime

    belongs_to :post, Blog.Models.Post
  end

  validate comment,
    body:    present(),
    post_id: present()

  def find([id | _] = ids) when is_binary(id) do
    ids |> Enum.map(&String.to_integer(&1)) |> find
  end

  def find(ids) when is_list(ids) do
    Repo.all(from m in __MODULE__, where: m.id in array(^ids, :integer))
  end

  def find(id) when is_binary(id) do
    id |> String.to_integer |> find
  end

  def find(id) do
    Repo.one(from m in __MODULE__, where: m.id == ^id)
  end

  def all do
    Repo.all(from m in __MODULE__, [])
  end

  def for_post(post_id) when is_binary(post_id) do
    post_id |> String.to_integer |> for_post
  end

  def for_post(post_id) do
    Repo.all(from m in __MODULE__, where: m.post_id == ^post_id)
  end

  @doc """
  Validates and creates a comment given a map of attributes
  """
  def create(params) do
    model = %__MODULE__{
      body:    params[:body],
      post_id: params[:post_id]
    }

    case validate(model) do
      []     -> {:ok,    Repo.insert(model)}
      errors -> {:error, errors}
    end
  end
end
