class AddNotificationPreferencesToUser < ActiveRecord::Migration
  def change
    add_column :users, :notification_preferences, :jsonb, null: false, default: '{}'
  end
end
