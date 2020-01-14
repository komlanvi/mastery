defmodule Mastery.Core.Quiz do
  alias Mastery.Core.{Template, Question, Response}

  defstruct title: nil,
            mastery: 3,
            templates: %{},
            used: [],
            mastered: [],
            current_question: nil,
            last_response: nil,
            record: %{}

  def new(fields) do
    struct!(__MODULE__, fields)
  end

  def add_template(quiz, fields) do
    template = Template.new(fields)

    templates = update_in(quiz.templates, [template.category], &add_to_list_or_nil(&1, template))
    %{quiz | templates: templates}
  end

  defp add_to_list_or_nil(nil, template), do: [template]
  defp add_to_list_or_nil(templates, template), do: [template | templates]

  def select_question(%__MODULE__{templates: templates}) when map_size(templates) == 0, do: 0

  def select_question(quiz) do
    quiz
    |> pick_current_question()
    |> move_template(:used)
    |> reset_template_cycle()
  end

  defp pick_current_question(quiz) do
    Map.put(
      quiz,
      :current_question,
      select_random_question(quiz)
    )
  end

  defp select_random_question(quiz) do
    quiz.templates
    |> Enum.random()
    |> elem(1)
    |> Enum.random()
    |> Question.new()
  end

  defp move_template(quiz, field) do
    quiz
    |> remove_template_from_category()
    |> add_template_to_field(field)
  end

  defp remove_template_from_category(quiz) do
    template = template(quiz)

    new_category_templates =
      quiz.templates
      |> Map.fetch!(template.category)
      |> List.delete(template)

    new_templates =
      if new_category_templates == [] do
        Map.delete(quiz.templates, template.category)
      else
        Map.put(quiz.templates, template.category, new_category_templates)
      end

    Map.put(quiz, :templates, new_templates)
  end

  defp add_template_to_field(quiz, field) do
    template = template(quiz)
    field_list = Map.get(quiz, field)

    Map.put(quiz, field, [template | field_list])
  end

  defp template(quiz), do: quiz.current_question.template

  defp reset_template_cycle(%{templates: templates, used: used} = quiz)
       when map_size(templates) == 0 do
    %__MODULE__{
      quiz
      | templates: Enum.group_by(used, fn template -> template.category end),
        used: []
    }
  end

  defp reset_template_cycle(quiz), do: quiz

  def answer_question(quiz, %Response{correct: true} = response) do
    new_quiz =
      quiz
      |> increment_record()
      |> save_response(response)

    maybe_advance(new_quiz, mastered?(new_quiz))
  end

  def answer_question(quiz, %Response{correct: false} = response) do
    quiz
    |> reset_record()
    |> save_response(response)
  end

  defp save_response(quiz, response) do
    Map.put(quiz, :last_response, response)
  end

  defp increment_record(quiz) do
    new_record = Map.update(quiz.record, template(quiz).name, 1, &(&1 + 1))
    Map.put(quiz, :record, new_record)
  end

  defp mastered?(quiz) do
    score = Map.get(quiz.record, template(quiz).name, 0)
    score == quiz.mastery
  end

  defp maybe_advance(quiz, false), do: quiz
  defp maybe_advance(quiz, true), do: advance(quiz)

  defp advance(quiz) do
    quiz
    |> move_template(:mastered)
    |> reset_record()
    |> reset_used()
  end

  defp reset_record(quiz) do
    new_record = Map.delete(quiz.record, template(quiz))
    Map.put(quiz, :record, new_record)
  end

  defp reset_used(quiz) do
    new_used = List.delete(quiz.used, template(quiz))
    Map.put(quiz, :used, new_used)
  end
end
