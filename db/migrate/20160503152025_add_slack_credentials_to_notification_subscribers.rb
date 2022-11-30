class AddSlackCredentialsToNotificationSubscribers < ActiveRecord::Migration
  def change
    add_column :notifications_subscribers, :options, :jsonb, null: false, default: {}
  end
end
