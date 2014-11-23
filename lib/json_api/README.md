# Relax

A JsonAPI.org implimentation in Elixir.

## Rational

TLDR: Generate a proper JsonAPI.org server as simply as possible.

In order to drive Elixir adoption in my day to day work (Agilion.com) the absolute first thing needed is an easy way to build JSON Rest APIs suitable for comsumption by Ember.js. While this is certainly acheivable with existing Elixir tooling (like the powerful Pheonix Framework), I was looking for something that gave me exactly what was needed and nothing that wasn't.

In particular generating the proper JsonAPI.org format with as little ceremony as possible, including handling all the content type, url routing, JSON structure, and various relationship options.

Further, the serialization DSL is inflenced heavily by ActiveModel::Serializers.

## Installation

hex etc

## Usage

Relax is composed of 4 distinct layers of functionaliy, each of which builds upon the last, yet allows flexiability to integrate with the tools you already in use.

1. The serialization layer - Combine a struct and a conn to generate JsonAPI.org format.
2. Rendering helpers - Handle calling the serializers and returning the proper response.
3. Deserialization helpers - Take a JsonAPI.org POST/PUT/PATCH request, deserialize it, and provide params.
4. Routing layer - Handle the specified JsonAPI.org url structures. eg: /v1/comments/1 vs /v1/comments/1,2,3

### Basic Serialization

It should be possible to integrate Relaxir into any existing applications/frameworks just using the serialization layer.

Given any map data structure:

```elixir
defmodel MyApp.Models.Post do
  defstruct id: nil, title: "Foo", body: "Bar", posted_at: nil, comment_ids: []
end

defmodel MyApp.Models.Comment do
  defstruct id: nil, post_id: nil, body: "spam"
end
```

You can use a seperate DSL to define the json representation. Each serializer the presentation data structure based on the model and connection.

```elixir
defmodule MyApp.Serializers.V1.Post do
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
# In a standard plug:
json = %MyApp.Models.Post{id: 1, title: "Foo"}
  |> MyApp.Serializers.V1.Post.as_json(conn)
  |> Poison.Encoder.encode([])
# Don't forget the jsonapi.org content type!
conn
  |> put_resp_header("content-type", "application/vnd.api+json")
  |> send_resp(200, json)
```

### Response helpers

This layer lets you quickly abstract calling serializers and sending responses.


```elixir
# Simple plug example
defmodule MyApp.API.V1.Posts do
  use Plug.Router
  use Relaxir.Responders

  serializer MyApp.Serializers.V1.Post

  plug :match
  plug :dispatch

  get "/posts" do
    okay(conn, %MyApp.Models.Post{id: 1, title: "Foo"})
  end
end
```

### Params helpers

This layer is all about creating and updating your resources. It includes a plug parser to handle the JsonAPI.org content type, and an interface for filtering and transforming the request to the map you need.

```elixir
# Simple plug example
defmodule MyApp.API.V1.Posts do
  use Plug.Router
  use Relaxir.Responders
  use JsonApi.Params

  serializer MyApp.Serializers.V1.Post

  plug Plug.Parsers, parsers: [JsonApi.PlugParser]
  plug :match
  plug :dispatch

  post "/posts" do
    filter_params(conn, {"posts", [:title, :body]}) do
      case MyApp.Models.Post.create(params) do
        {:ok,    post}   -> created(conn, post)
        {:error, errors} -> invalid(conn, errors)
      end
    end
  end
end
```

### Relixir Routing

This is the final layer, and wraps those above. It provides a Router and a Resource.

A Router is a extremely simple plug router inspired by and based on the fantastic work by Chris McCord in Pheonix, but focused on Restful APIs implementing the jsonapi.org spec. Namely providing an easy interface for dealing with versioning and the various GET calls.

```elixir
defmodule Router do
  use Relaxir.Router

  version :v1 do
    resource :posts, API.V1.Posts, except: [:create, :update] do
      resource :comments, API.V1.Comments, only: [:find_all]
    end
    resource :comments, API.V1.Comments, except: [:find_all]
  end
end
```

A resource includes all our response and params helpers in a tidy api.

```elixir

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

