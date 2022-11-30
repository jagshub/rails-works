class AddDescriptionToUpcomingPageQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_questions, :description, :string, null: true
  end
end
