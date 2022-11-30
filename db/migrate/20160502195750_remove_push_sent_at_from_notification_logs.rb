class RemovePushSentAtFromNotificationLogs < ActiveRecord::Migration
  def change
    remove_column :notification_logs, :push_sent_at, :datetime, null: true
  end
end
