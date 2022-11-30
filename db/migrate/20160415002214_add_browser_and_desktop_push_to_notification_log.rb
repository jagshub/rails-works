class AddBrowserAndDesktopPushToNotificationLog < ActiveRecord::Migration
  def change
    add_column :notification_logs, :browser_push_sent_at, :timestamp, null: true
    add_column :notification_logs, :desktop_push_sent_at, :timestamp, null: true
  end
end
