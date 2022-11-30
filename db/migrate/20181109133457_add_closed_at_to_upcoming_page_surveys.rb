class AddClosedAtToUpcomingPageSurveys < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_surveys, :closed_at, :datetime, null: true
  end
end
