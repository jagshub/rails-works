class CreateUpcomingPageQuestions < ActiveRecord::Migration
  def change
    create_table :upcoming_page_questions do |t|
      t.string :title, null: false
      t.references :upcoming_page, null: false
      t.datetime :trashed_at, null: true
      t.timestamps null: false
    end

    add_foreign_key :upcoming_page_questions, :upcoming_pages
  end
end
