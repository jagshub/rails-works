class AddNotificationSettingsUpvotedByFriends < ActiveRecord::Migration
  def change
    add_column :notifications_settings, :send_upvoted_by_friends_email, :boolean, null: false, default: true
  end
end
