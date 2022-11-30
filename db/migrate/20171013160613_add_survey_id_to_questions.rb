class AddSurveyIdToQuestions < ActiveRecord::Migration
  def change
    add_reference :upcoming_page_questions, :upcoming_page_survey, index: true
    add_foreign_key :upcoming_page_questions, :upcoming_page_surveys
  end
end
