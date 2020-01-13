defmodule Mastery.Core.Question do
  @moduledoc """
  A quiz question

  :template => a template with variables eg. <%= left %> + <%= right %>.
  :substitutions => a list of variables present in the template with predefined values
  :asked => the string the user see which is obtained applying substitutions to template
  """
  alias Mastery.Core.Template
  defstruct [:asked, :substitutions, :template]

  def new(%Template{} = template) do
    template.generators
    |> Enum.map(&build_substitution/1)
    |> evaluate(template)
  end

  defp build_substitution({name, choices_or_generator}) do
    {name, choose(choices_or_generator)}
  end

  defp choose(choices) when is_list(choices) do
    Enum.random(choices)
  end

  defp choose(generator) when is_function(generator) do
    generator.()
  end

  defp compile(template, substitutions) do
    template.compiled
    |> Code.eval_quoted(assigns: substitutions)
    |> elem(0)
  end

  defp evaluate(substitutions, template) do
    %__MODULE__{
      asked: compile(template, substitutions),
      substitutions: substitutions,
      template: template
    }
  end
end
