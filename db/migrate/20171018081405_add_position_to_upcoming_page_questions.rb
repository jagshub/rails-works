class AddPositionToUpcomingPageQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_questions, :position_in_survey, :integer, default: 0, null: false
    add_column :upcoming_page_questions, :question_type, :integer, default: 0, null: false
  end
end
