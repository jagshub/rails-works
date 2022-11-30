class AddStatusToUpcomingPages < ActiveRecord::Migration
  def change
    add_column :upcoming_pages, :status, :integer, default: 0
  end
end
