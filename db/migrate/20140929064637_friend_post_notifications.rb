class FriendPostNotifications < ActiveRecord::Migration
  def change
    change_column :users, :comment_notifications, :boolean, null: false, default: true
    change_column :users, :login_count, :integer, null: false, default: 1

    add_column :users, :friend_post_notifications, :boolean, null: false, default: true
    add_column :users, :last_friend_post_notification_at, :timestamp, null: true
  end
end
