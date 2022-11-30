class AddAbStartedAtToUpcomingPages < ActiveRecord::Migration
  def change
    add_column :upcoming_pages, :ab_started_at, :datetime, null: true
  end
end
