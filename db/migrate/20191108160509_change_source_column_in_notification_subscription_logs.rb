class ChangeSourceColumnInNotificationSubscriptionLogs < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      change_column :notification_subscription_logs, :source, :string
    end
  end
end
