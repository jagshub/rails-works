class AddFeatureNotificationsSentAtToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :feature_notifications_sent_at, :datetime, null: true
  end
end
