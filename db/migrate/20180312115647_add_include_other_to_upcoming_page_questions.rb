class AddIncludeOtherToUpcomingPageQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_questions, :include_other, :boolean, default: false, null: false
  end
end
