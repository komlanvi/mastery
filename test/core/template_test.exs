defmodule MasteryTest.TemplateTest do
  use ExUnit.Case
  use Mastery.TestDefaultImports
  use MasteryTest.QuizBuilders

  test "building compile the raw template" do
    fields = template_fields()
    template = Template.new(fields)

    assert is_nil(Keyword.get(fields, :compiled))
    assert not is_nil(template.compiled)
  end
end
