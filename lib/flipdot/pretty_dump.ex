defmodule Flipdot.PrettyDump do
  defmacro pretty_dump(var, name) do
    quote do
      inspect(unquote(var), limit: :infinity, pretty: true)
      |> then(&File.write!("tmp/" <> unquote(name) <> ".txt", &1))

      unquote(var)
    end
  end
end
