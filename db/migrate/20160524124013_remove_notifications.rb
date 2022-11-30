class RemoveNotifications < ActiveRecord::Migration
  def change
    drop_table :notifications
    remove_column :users, :notifications_count
    remove_column :users, :unseen_notifications_count
  end
end
