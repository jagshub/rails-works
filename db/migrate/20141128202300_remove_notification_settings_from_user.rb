class RemoveNotificationSettingsFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :comment_notifications
    remove_column :users, :friend_post_notifications
  end
end
