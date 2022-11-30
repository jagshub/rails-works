class RemoveUnusedNotificationIndexes < ActiveRecord::Migration
  def change
    remove_index :notifications, name: :index_notifications_on_post_id
    remove_index :notifications, name: :index_notifications_on_comment_id
  end
end
