class AddTrashedAtToUpcomingPageSurveys < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_surveys, :trashed_at, :datetime, null: true
  end
end
