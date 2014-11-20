# Relax

A JsonAPI.org implimentation in Elixir.


## Installation

hex etc

## Usage

Relaxir can be used in a few different ways:

1. Only for serialization (eg, inside another framework).
2. Integrated as a basic plug "route".
3. Providing a full plug based routing stack.

### Basic Serialization

It should be possible to integrate Relaxir into any existing applications/frameworks this way.

Given any map data structure:

```elixir
defmodel Post do
  defstruct id: nil, title: "Foo", body: "Bar", posted_at: nil, comment_ids: []
end

defmodel Comment do
  defstruct id: nil, post_id: nil, body: "spam"
end
```

You can use a seperate DSL to define the json representation:

```elixir
defmodule Serializer.V1.Post do
  use Relax.Serializer

  serialize "posts" do
    attributes [:id, :title, :body, :is_published]
    has_many :comments, ids: true
  end

  def is_published(post, _conn) do
    post.posted_at != nil
  end

  def comments(post, _conn) do
    post.comment_ids
  end
end
```

You can then pass the model to the serializer to get the jsonapi.org formated data structure for conversion to JSON.

```elixir
json = %Post{id: 1, title: "Foo"}
  |> Serializer.V1.Post.as_json(conn)
  |> Poison.Encoder.encode([])
# Don't forget the jsonapi.org content type!
conn
  |> put_resp_header("content-type", "application/vnd.api+json")
  |> send_resp(200, json)
```

# Using Plug routing

If you are already using Plug routing directly (most likely with forwards) this approach will be easy to hook into your existing app.


```elixir
defmodule API.V1 do
  use Plug.Router
  plug :match
  plug :dispatch

  forward "/v1/posts", to: API.V1.Posts
end


defmodule API.V1.Posts do
  use Relaxir.Resource

  serializer Serializer.V1.Post

  get "/posts" do
    okay(conn, %Post{id: 1, title: "Foo"})
  end

  post "/posts" do
    filter_params(conn, {"posts", [:title, :body]}) do
      case Post.create(params) do
        {:ok,    post}   -> created(conn, post)
        {:error, errors} -> invalid(conn, errors)
      end
    end
  end
end
```

## Relixir Routing

```elixir

defmodule Router do
  use Relaxir.Router

  version :v1 do
    resource :posts,    API.V1.Posts,    only:   [:find_all, :find_one, :find_many]
    resource :comments, API.V1.Comments, except: [:destroy]
  end
end

defmodule API.V1.Posts do
  use Relaxir.Resource

  serializer Serializers.V1.Post

  def find_all(conn) do
    okay(conn, Post.all)
  end

  def find_one(conn, id) do
    case Post.find(id) do
      nil  -> not_found(conn)
      post -> okay(conn, post)
    end
  end

  def find_many(conn, list_of_ids) do
    okay(conn, Post.find(list_of_ids))
  end
end

```

