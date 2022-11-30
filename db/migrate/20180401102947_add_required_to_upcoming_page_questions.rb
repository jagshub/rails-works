class AddRequiredToUpcomingPageQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_questions, :required, :boolean, null: false, default: false
  end
end
