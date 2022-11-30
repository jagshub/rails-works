class CreateUpcomingPageSurveyRules < ActiveRecord::Migration[5.0]
  def change
    create_table :upcoming_page_question_rules do |t|
      t.references :upcoming_page_question, null: false

      t.integer :dependent_upcoming_page_option_id, null: false
      t.integer :dependent_upcoming_page_question_id, null: false

      t.timestamps null: false
    end
  end
end
