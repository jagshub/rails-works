class AddIndexNotificationLogsExists < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :notification_logs, [:kind, :notifyable_type, :notifyable_id], algorithm: :concurrently, name: 'idx_notification_logs_on_kind_and_notifyable_type_and_notify_id'
  end
end
