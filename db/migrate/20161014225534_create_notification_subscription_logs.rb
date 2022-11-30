class CreateNotificationSubscriptionLogs < ActiveRecord::Migration
  def change
    create_table :notification_subscription_logs do |t|
      t.integer :subscriber_id, null: false, index: true
      t.integer :kind, null: false, index: true
      t.string :channel_name, null: false
      t.string :setting_details
      t.integer :source, null: false, index: true
      t.string :source_details

      t.timestamps null: false
    end
  end
end
