class DetachShipAccountFromSurvey < ActiveRecord::Migration[5.0]
  def change
    remove_column :upcoming_page_surveys, :ship_account_id
    remove_column :upcoming_page_question_answers, :ship_contact_id
  end
end
