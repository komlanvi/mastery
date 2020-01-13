defmodule Mastery.Core.Question do
  @moduledoc """
  A quiz question

  :template => a template with variables eg. <%= left %> + <%= right %>.
  :substitutions => a list of variables present in the template with predefined values
  :asked => the string the user see which is obtained applying substitutions to template
  """
  defstruct [:asked, :substitutions, :template]
end
