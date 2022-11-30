class SwitchUniqueConstraintsForNotificationLogs < ActiveRecord::Migration
  disable_ddl_transaction!

  def up
    change_column_null :notification_logs, :subscriber_id, false
    add_index :notification_logs, [:subscriber_id, :kind, :notifyable_id, :notifyable_type], unique: true, name: 'notification_logs_unique', algorithm: :concurrently

    remove_index :notification_logs, column: [:user_id, :kind, :notifyable_id, :notifyable_type], unique: true, name: 'notification_logs_unqiue'
    change_column_null :notification_logs, :user_id, true
    remove_foreign_key :notification_logs, :users
  end

  def down
    change_column_null :notification_logs, :user_id, false
    add_index :notification_logs, [:user_id, :kind, :notifyable_id, :notifyable_type], unique: true, name: 'notification_logs_unqiue', algorithm: :concurrently
    add_foreign_key :notification_logs, :users

    change_column_null :notification_logs, :subscriber_id, true
    remove_index :notification_logs, column: [:subscriber_id, :kind, :notifyable_id, :notifyable_type], unique: true, name: 'notification_logs_unique'
  end
end
