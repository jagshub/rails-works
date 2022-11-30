class RemoveNeedForUpcomingPageIdInQuestions < ActiveRecord::Migration[5.0]
  def change
    change_column_null :upcoming_page_questions, :upcoming_page_id, true
  end
end
