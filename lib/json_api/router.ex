defmodule JsonApi.Router do

  defmacro __using__(_) do
    quote do
      import JsonApi.Router
      use Plug.Router
    end
  end

  defmacro version(version, do: block) do
    quote do
      @version Atom.to_string(unquote(version))
      @nested_in nil
      unquote(block)
      @version nil
    end
  end

  defmacro resource(name, module) do
    forward_resource(name, module)
  end

  defmacro resource(name, module, do: block) do
    forward_resource(name, module, block)
  end

  # This is basically a forwarding dsl
  defp forward_resource(name, target) do
    name = Atom.to_string(name)
    quote do
      case @nested_in do
        nil -> 
          defp do_match(_mthd, [@version, unquote(name) | glob]) do
            fn(conn) ->
              opts = unquote(target).init([])
              Plug.Router.Utils.forward(conn, glob, unquote(target), opts)
            end
          end
        nested_name ->
          defp do_match(_mthd, [@version, nested_name, parent_id, unquote(name) | glob]) do
            fn(conn) ->
              opts = unquote(target).init([])
              conn
              |> Plug.Conn.put_private(:relax_parent_name, nested_name)
              |> Plug.Conn.put_private(:relax_parent_id,   parent_id)
              |> Plug.Router.Utils.forward(glob, unquote(target), opts)
            end
          end
      end
    end
  end

  defp forward_resource(name, module, block) do
    quote do
      @nested_in Atom.to_string(unquote(name))
      unquote(block)
      @nested_in nil
      unquote(forward_resource(name, module))
    end
  end
end
