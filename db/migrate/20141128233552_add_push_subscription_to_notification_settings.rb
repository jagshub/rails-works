class AddPushSubscriptionToNotificationSettings < ActiveRecord::Migration
  def change
    add_column :notifications_settings, :subscribed_to_push, :boolean, null: false, default: false
  end
end
