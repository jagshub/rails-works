class AddShipContactIdToUpcomingPageQuestionAnswer < ActiveRecord::Migration[5.0]
  def change
    add_reference :upcoming_page_question_answers, :ship_contact, foreign_key: true, index: true, null: true
  end
end
