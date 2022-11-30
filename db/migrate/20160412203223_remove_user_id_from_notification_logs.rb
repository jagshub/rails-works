class RemoveUserIdFromNotificationLogs < ActiveRecord::Migration
  def change
    remove_column :notification_logs, :user_id, :integer
  end
end
