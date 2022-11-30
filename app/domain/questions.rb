# frozen_string_literal: true

module Questions
  extend self

  def import_csv_form
    Questions::ImportCSV.new
  end

  def import_csv_form_hint
    Questions::ImportCSV::HINT
  end

  def related_to(question)
    question.post.questions.where.not(id: question.id).by_random.first(5)
  end
end
