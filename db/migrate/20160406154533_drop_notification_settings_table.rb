class DropNotificationSettingsTable < ActiveRecord::Migration
  def change
    drop_table :notifications_settings
  end
end
