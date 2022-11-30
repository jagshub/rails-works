class AddFreetextToUpcomingPageQuestionAnswers < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_question_answers, :freeform_text, :text
  end
end
