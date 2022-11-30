class AddMobilePushSentAtToNotificationLogs < ActiveRecord::Migration
  def change
    add_column :notification_logs, :mobile_push_sent_at, :datetime, null: true
  end
end
