class AddUniqueIndexToTokensInNotificationsSubscribers < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :notifications_subscribers, [:user_id], unique: true, algorithm: :concurrently
    add_index :notifications_subscribers, [:browser_push_token], unique: true, algorithm: :concurrently
    add_index :notifications_subscribers, [:mobile_push_token], unique: true, algorithm: :concurrently
    add_index :notifications_subscribers, [:desktop_push_token], unique: true, algorithm: :concurrently
  end
end
