class RequireSurveyIdForUpcomingPageQuestion < ActiveRecord::Migration[5.0]
  def change
    change_column_null :upcoming_page_questions, :upcoming_page_survey_id, false
  end
end
