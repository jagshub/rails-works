class AddSubscriberCountToUpcomingPages < ActiveRecord::Migration
  def change
    add_column :upcoming_pages, :subscriber_count, :integer, null: false, default: 0
  end
end
