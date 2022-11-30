class AddNotificationsFeedAttrsToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :notification_feed_items_unread_count, :integer
    add_column :users, :notification_feed_last_seen_at, :datetime
  end
end
