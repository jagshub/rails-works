class AddDesktopPushTokenToNotificationSubscribers < ActiveRecord::Migration
  def change
    add_column :notifications_subscribers, :desktop_push_token, :string, nil: true
  end
end
