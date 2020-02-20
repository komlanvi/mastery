defmodule Mastery.Core.Response do
  @moduledoc """
  A response provided by a user
  """

  defstruct [:quiz_title, :template_name, :to, :email, :answer, :correct, :timestamp]

  def new(quiz, email, answer) do
    question = quiz.current_question
    template = question.template

    %__MODULE__{
      quiz_title: quiz.title,
      template_name: template.name,
      to: question.asked,
      email: email,
      answer: answer,
      correct: template.checker.(question.substitutions, answer),
      timestamp: DateTime.utc_now()
    }
  end
end
