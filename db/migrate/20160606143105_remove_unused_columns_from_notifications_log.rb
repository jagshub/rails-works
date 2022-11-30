class RemoveUnusedColumnsFromNotificationsLog < ActiveRecord::Migration
  def change
    remove_column :notification_logs, :email_sent_at
    remove_column :notification_logs, :browser_sent_at
    remove_column :notification_logs, :browser_push_sent_at
    remove_column :notification_logs, :desktop_push_sent_at
    remove_column :notification_logs, :mobile_push_sent_at
    remove_column :notification_logs, :slack_sent_at
  end
end
