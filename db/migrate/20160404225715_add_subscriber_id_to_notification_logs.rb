class AddSubscriberIdToNotificationLogs < ActiveRecord::Migration
  def change
    # TODO(andreasklinger): remove user_id in followup PR
    # TODO(andreasklinger): enforce non-null in followup PR
    add_column :notification_logs, :subscriber_id, :integer, null: true
    add_foreign_key :notification_logs, :notifications_subscribers, column: :subscriber_id
  end
end
