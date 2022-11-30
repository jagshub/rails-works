class AddKindToUpcomingPageQuestionAnswers < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_question_answers, :kind, :integer, default: 0, null: false
  end
end
