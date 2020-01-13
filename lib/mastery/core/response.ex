defmodule Mastery.Core.Response do
  @moduledoc """
  A response provided by a user
  """

  defstruct [:quiz_title, :template_name, :to, :email, :answer, :correct, :timestamps]
end
