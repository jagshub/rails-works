class CreateUpcomingPageQuestionAnswers < ActiveRecord::Migration
  def change
    create_table :upcoming_page_question_options do |t|
      t.string :title, null: false
      t.references :upcoming_page_question, null: false
      t.datetime :trashed_at, null: true
      t.timestamps null: false
    end

    add_foreign_key :upcoming_page_question_options, :upcoming_page_questions
  end
end
