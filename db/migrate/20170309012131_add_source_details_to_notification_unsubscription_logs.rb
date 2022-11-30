class AddSourceDetailsToNotificationUnsubscriptionLogs < ActiveRecord::Migration
  def change
    add_column :notification_unsubscription_logs, :source_details, :string
  end
end
