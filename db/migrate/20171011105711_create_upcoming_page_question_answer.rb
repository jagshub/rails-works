class CreateUpcomingPageQuestionAnswer < ActiveRecord::Migration
  def change
    create_table :upcoming_page_question_answers do |t|
      t.references :upcoming_page_question_option, null: false
      t.references :upcoming_page_subscriber, null: false
      t.timestamps null: false
    end

    add_foreign_key :upcoming_page_question_answers, :upcoming_page_question_options
    add_foreign_key :upcoming_page_question_answers, :upcoming_page_subscribers
  end
end
