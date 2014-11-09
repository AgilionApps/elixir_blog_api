defmodule Blog.Models.Post do
  use    Ecto.Model
  import Ecto.Query, only: [from: 2]
  alias  Blog.Repo

  schema "posts" do
    field :title,      :string
    field :body,       :string
    field :posted_at,  :datetime
    field :created_at, :datetime
    field :updated_at, :datetime

    has_many :comments, Blog.Models.Comment
  end

  validate post,
    title: present(),
    body:  present()

  def all do
    Repo.all(from m in __MODULE__, preload: [:comments])
  end

  def find(id) do
    Repo.one(from m in __MODULE__, where: m.id == ^id, preload: [:comments])
  end

  @doc """
  Validates and creates a post given a map of attributes
  """
  def create(params) do
    model = %__MODULE__{
      title: params[:title],
      body:  params[:body]
    }

    case validate(model) do
      []     -> {:ok,    Repo.insert(model)}
      errors -> {:error, errors}
    end
  end
end
