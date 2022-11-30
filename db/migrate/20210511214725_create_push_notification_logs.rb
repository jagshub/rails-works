class CreatePushNotificationLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :notification_push_logs do |t|
      t.string :uuid, null: false
      t.string :channel, null: false
      t.string :kind, null: false
      t.boolean :received, default: false
      t.boolean :converted, default: false
      t.string :url, null: true
      t.string :platform, null: false
      t.string :delivery_method, null: false
      t.datetime :sent_at, null: false
      t.jsonb :raw_response, null: false

      t.integer :user_id, null: true
      t.integer :notification_event_id, null: true
      t.timestamps
    end

    add_index :notification_push_logs, :uuid, :unique => true
  end
end
