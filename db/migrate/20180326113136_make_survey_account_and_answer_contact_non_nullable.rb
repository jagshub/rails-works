class MakeSurveyAccountAndAnswerContactNonNullable < ActiveRecord::Migration[5.0]
  def change
    change_column_null :upcoming_page_surveys, :ship_account_id, false
    change_column_null :upcoming_page_question_answers, :ship_contact_id, false
  end
end
