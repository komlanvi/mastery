defmodule Mastery.TestDefaultImports do
  defmacro __using__(_) do
    quote do
      alias Mastery.Core.{Template, Response, Quiz}
    end
  end
end
