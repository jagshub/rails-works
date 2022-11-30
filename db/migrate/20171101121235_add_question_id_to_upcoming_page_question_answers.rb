class AddQuestionIdToUpcomingPageQuestionAnswers < ActiveRecord::Migration[5.0]
  def change
    add_reference :upcoming_page_question_answers, :upcoming_page_question, index: { name: 'index_upcoming_question_answers_on_upcoming_question_id' }
    add_foreign_key :upcoming_page_question_answers, :upcoming_page_questions
  end
end
