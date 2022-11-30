class MakeUpcomingPageQuestionOptionIdNullable < ActiveRecord::Migration[5.0]
  def change
    change_column_null :upcoming_page_question_answers, :upcoming_page_question_option_id, true
  end
end
