defmodule JsonApi.Router do

  defmacro __using__(_) do
    quote do
      import JsonApi.Router
      use Plug.Router
    end
  end

  # super niave implementaion
  defmacro version(version, do: block) do
    quote do
      @version Atom.to_string(unquote(version))
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

  # This is basically a forward plus adding parent id
  defp forward_resource(name, target) do
    name = Atom.to_string(name)
    quote do
      defp do_match(_mthd, [@version, unquote(name) | glob]) do
        fn(conn) ->
          opts = unquote(target).init([])
          Plug.Router.Utils.forward(conn, glob, unquote(target), opts)
        end
      end
    end
  end

  defp forward_resource(_name, _module, block) do
    quote do

      unquote(block)
    end
  end
end
