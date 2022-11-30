class RemoveLastFriendPostNotificationAtFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :last_friend_post_notification_at, :datetime
  end
end
