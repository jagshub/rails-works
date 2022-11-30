class AddSlackSendAtToNotificaitonsLog < ActiveRecord::Migration
  def change
    add_column :notification_logs, :slack_sent_at, :timestamp, null: true
  end
end
