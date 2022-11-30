class AddTrashedAtToUpcomingPages < ActiveRecord::Migration
  def change
    add_column :upcoming_pages, :trashed_at, :timestamp, null: true
  end
end
