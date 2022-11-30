class RemoveLegacySurveyColumns < ActiveRecord::Migration[5.0]
  def change
    remove_column :upcoming_page_questions, :upcoming_page_id
    remove_column :upcoming_pages, :survey_status
  end
end
