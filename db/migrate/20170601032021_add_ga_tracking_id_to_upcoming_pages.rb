class AddGaTrackingIdToUpcomingPages < ActiveRecord::Migration
  def change
    add_column :upcoming_pages, :ga_tracking_id, :string
  end
end
